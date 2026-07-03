//
//  LoginView.swift
//  TrainingAssistant
//
//  The signed-out screen. Offers Apple (native) and Google (browser) sign-in,
//  both routed through `AuthService`. Shown by `RootView` whenever there is no
//  session.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthService.self) private var authService
    /// The raw nonce for the in-flight Apple request; its hash goes to Apple, the
    /// raw value goes to Supabase once Apple returns the identity token.
    @State private var currentNonce: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "dog.fill")
                .imageScale(.large)
                .font(.system(size: 48))
                .foregroundStyle(.tint)
            Text("Training Assistant")
                .font(.title2.weight(.semibold))
            Text("Sign in to continue. Accounts are invite-only.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                SignInWithAppleButton(.signIn) { request in
                    let nonce = AuthService.randomNonce()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = AuthService.sha256(nonce)
                } onCompletion: { result in
                    handleAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)

                Button {
                    Task { await authService.signInWithGoogle() }
                } label: {
                    Label("Continue with Google", systemImage: "globe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .disabled(authService.isBusy)

            if let error = authService.authError {
                Text(error.text)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            Spacer()
        }
        .padding()
        .overlay {
            if authService.isBusy {
                ProgressView().controlSize(.large)
            }
        }
    }

    private func handleAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8),
                let nonce = currentNonce
            else {
                authService.report(AppleSignInError.missingToken)
                return
            }

            // TEMPORARY DIAGNOSTIC — remove once the invite/email issue is resolved.
            // Shows the email Apple actually put in the identity token and whether it's a
            // private-relay ("Hide My Email") alias — that value is exactly what the invite
            // hook compares against `invited_users`.
            print("🔎 credential.email =", credential.email ?? "nil (Apple only sends this on the FIRST authorization)")
            let tokenParts = idToken.split(separator: ".")
            if tokenParts.count >= 2 {
                var base64 = String(tokenParts[1])
                    .replacingOccurrences(of: "-", with: "+")
                    .replacingOccurrences(of: "_", with: "/")
                while base64.count % 4 != 0 { base64 += "=" }
                if let data = Data(base64Encoded: base64),
                   let claims = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("🔎 token email =", claims["email"] ?? "nil")
                    print("🔎 token is_private_email =", claims["is_private_email"] ?? "nil")
                }
            }

            Task { await authService.signInWithApple(idToken: idToken, nonce: nonce) }
        case .failure(let error):
            authService.report(error)
        }
    }

    private enum AppleSignInError: LocalizedError {
        case missingToken
        var errorDescription: String? {
            "Apple didn't return a usable identity token. Please try again."
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthService())
}
