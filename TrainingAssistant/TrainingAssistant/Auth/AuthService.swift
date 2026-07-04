//
//  AuthService.swift
//  TrainingAssistant
//
//  The app's single source of truth for authentication state. Wraps the Supabase
//  client, exposes the current session and sign-in/out actions, and keeps itself
//  current by listening to `auth.authStateChanges`.
//
//  Injected once in `TrainingAssistantApp` via `.environment(_:)` and read by
//  `RootView` (to gate the app) and `LoginView` (to sign in).
//

import Foundation
import Observation
import CryptoKit
import Security
import Supabase

/// A user-facing description of why sign-in isn't (yet) succeeding.
enum AuthErrorMessage: Equatable {
    /// The email isn't on the Supabase `invited_users` allowlist — surfaced by the
    /// "Before User Created" hook. Kept distinct so the UI can explain the fix.
    case notInvited
    /// `Supabase-Info.plist` is missing or empty — the app can't reach a backend.
    case notConfigured
    /// Any other failure, carrying the underlying message.
    case failed(String)

    var text: String {
        switch self {
        case .notInvited:
            return "You need an invitation to create an account. Ask your administrator "
                + "to invite your email address, then try signing in again."
        case .notConfigured:
            return "Sign-in isn't configured yet. Add Supabase-Info.plist to the app "
                + "target (see supabase/README.md)."
        case .failed(let message):
            return message
        }
    }
}

@MainActor
@Observable
final class AuthService {
    /// The current Supabase session, or `nil` when signed out.
    private(set) var session: Session?
    /// True while a sign-in/out request is in flight (for disabling UI).
    private(set) var isBusy = false
    /// The most recent user-facing error, if any. Cleared on a new attempt.
    private(set) var authError: AuthErrorMessage?

    /// Whether a usable Supabase configuration was found at launch.
    var isConfigured: Bool { client != nil }
    /// Whether a user is currently signed in.
    ///
    /// In Debug simulator builds we short-circuit to `true` so day-to-day UI work and
    /// (future) UI tests don't have to clear the Apple/Google login gate. This branch is
    /// compiled out of every device and Release build, so production auth is unaffected.
    var isSignedIn: Bool {
        #if DEBUG && targetEnvironment(simulator)
        return true
        #else
        return session != nil
        #endif
    }

    private let config: SupabaseConfig?
    private let client: SupabaseClient?
    private var authStateTask: Task<Void, Never>?

    init() {
        let config = SupabaseConfig.load()
        self.config = config
        if let config {
            self.client = SupabaseClient(supabaseURL: config.url, supabaseKey: config.anonKey)
            startListening()
        } else {
            self.client = nil
        }
    }

    // No `deinit` cleanup: this service is created once for the app's lifetime and is
    // never deallocated, and the auth-state task captures `self` weakly so it can't keep
    // the service alive. (A nonisolated `deinit` also can't touch the main-actor task.)

    // MARK: - Sign in

    /// Completes a native Sign in with Apple. `idToken` is Apple's identity token;
    /// `nonce` is the *raw* (un-hashed) nonce whose SHA-256 was sent in the request.
    func signInWithApple(idToken: String, nonce: String) async {
        await run {
            guard let client = self.client else { throw NotConfigured() }
            self.session = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: idToken,
                    nonce: nonce
                )
            )
        }
    }

    /// Browser-based Google OAuth (no native Google SDK in v1 — see design.md).
    func signInWithGoogle() async {
        await signInWithOAuth(.google)
    }

    /// Browser-based OAuth via `ASWebAuthenticationSession`. Kept provider-generic so
    /// additional browser providers (e.g. Facebook, deferred from v1) can be added by
    /// exposing another thin wrapper like `signInWithGoogle()`.
    private func signInWithOAuth(_ provider: Provider) async {
        await run {
            guard let client = self.client else { throw NotConfigured() }
            self.session = try await client.auth.signInWithOAuth(
                provider: provider,
                redirectTo: self.config?.redirectURL
            )
        }
    }

    // MARK: - Sign out

    func signOut() async {
        await run {
            guard let client = self.client else { throw NotConfigured() }
            try await client.auth.signOut()
            self.session = nil
        }
    }

    // MARK: - Errors surfaced from the UI

    /// Lets views (e.g. the Sign in with Apple button's failure path) route errors
    /// through the same classification used by the async sign-in methods.
    func report(_ error: Error) {
        classify(error)
    }

    func clearError() {
        authError = nil
    }

    // MARK: - Plumbing

    /// Runs a sign-in/out body with shared busy-state, error handling, and the
    /// "not configured" short-circuit.
    private func run(_ body: () async throws -> Void) async {
        authError = nil
        isBusy = true
        defer { isBusy = false }
        do {
            try await body()
        } catch is NotConfigured {
            authError = .notConfigured
        } catch {
            classify(error)
        }
    }

    /// Maps an underlying error to a user-facing `AuthErrorMessage`. The "not
    /// invited" case is detected by the message the Postgres hook returns (see
    /// supabase/schema.sql); user-cancelled sheets are swallowed silently.
    private func classify(_ error: Error) {
        let haystack = "\(error) \(error.localizedDescription)".lowercased()
        if haystack.contains("cancel") {
            return  // User dismissed the sheet — not worth surfacing.
        }
        if haystack.contains("invit") {
            authError = .notInvited
        } else {
            authError = .failed(error.localizedDescription)
        }
    }

    private func startListening() {
        guard let client else { return }
        authStateTask = Task { [weak self] in
            for await (_, session) in client.auth.authStateChanges {
                self?.session = session
            }
        }
    }

    private struct NotConfigured: Error {}

    // MARK: - Nonce helpers (for Sign in with Apple)

    /// A cryptographically random nonce string. Its SHA-256 is sent to Apple in the
    /// authorization request; the raw value is handed to Supabase to verify the token.
    static func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remaining = length
        while remaining > 0 {
            var byte: UInt8 = 0
            let status = SecRandomCopyBytes(kSecRandomDefault, 1, &byte)
            guard status == errSecSuccess else {
                fatalError("Unable to generate a secure nonce (OSStatus \(status))")
            }
            if byte < charset.count {
                result.append(charset[Int(byte)])
                remaining -= 1
            }
        }
        return result
    }

    /// Hex-encoded SHA-256 of `input`, as required for Apple's request nonce.
    static func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
