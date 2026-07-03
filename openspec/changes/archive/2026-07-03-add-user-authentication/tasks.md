## 1. Supabase project setup (outside repo — prerequisite for testing)

- [x] 1.1 Create the Supabase project (or dedicated environment) for TrainingAssistant
- [x] 1.2 Enable Apple and Google providers in Supabase Auth settings, using
      OAuth client credentials from each vendor's developer console (Facebook deferred)
- [x] 1.3 Create the `invited_users` table (`email`, `invited_by`, `invited_at`,
      `claimed_at`)
- [x] 1.4 Install a "Before User Created" Auth Hook (Postgres function) that rejects
      signup when `user.email` is not present in `invited_users`
- [x] 1.5 Insert at least one test email into `invited_users` for manual verification

## 2. Xcode project setup

- [x] 2.1 Add the `supabase-swift` package (Auth module) via Swift Package Manager
- [x] 2.2 Enable the "Sign in with Apple" capability in the Xcode project
- [x] 2.3 Add Supabase project URL/anon key configuration (e.g. an `.xcconfig` or
      plist entry, not hardcoded/committed as a secret)
      <!-- Code mechanism done: SupabaseConfig loader + Supabase-Info.example.plist
           template + .gitignore entry. User still fills in the real plist values. -->


## 3. AuthService

- [x] 3.1 Create `AuthService` (`@Observable`) wrapping the Supabase client, exposing
      current session/user state
- [x] 3.2 Implement `signInWithApple()` using `AuthenticationServices` +
      `supabase.auth.signInWithIdToken(credentials:)`
- [x] 3.3 Implement `signInWithGoogle()` using `supabase.auth.signInWithOAuth(provider: .google)`
- [x] 3.5 Implement `signOut()`
- [x] 3.6 Subscribe to `supabase.auth.authStateChanges` to keep session state current
      across `INITIAL_SESSION`/`SIGNED_IN`/`SIGNED_OUT`/`TOKEN_REFRESHED` events
- [x] 3.7 Surface the "not invited" signup rejection as a distinct, user-facing error
      case (not a generic failure)

## 4. UI: LoginView and RootView

- [x] 4.1 Create `LoginView` with Apple/Google sign-in buttons, wired to
      `AuthService`
- [x] 4.2 Show the "not invited" message clearly in `LoginView` when signup is
      rejected
- [x] 4.3 Create `RootView` that branches on `authService`'s signed-in state between
      `LoginView` and the existing `ContentView`
- [x] 4.4 Wire `AuthService` into `TrainingAssistantApp.swift` via `.environment(authService)`,
      alongside the existing `.modelContainer(container)`
- [x] 4.5 Change the scene's root content in `TrainingAssistantApp.swift` from
      `ContentView` to `RootView`
- [x] 4.6 Add a sign-out affordance reachable from within the existing app (e.g. in
      `SettingsView`)

## 5. Manual verification

- [x] 5.1 Attempt signup with a non-invited email via Apple and Google —
      confirm rejection with a clear message and no row created in Supabase
      `auth.users` for either
- [x] 5.2 Complete signup with the pre-invited test email via each provider
      (Apple, Google) — confirm each lands signed-in on `ContentView`
- [x] 5.3 Force-quit and relaunch the app while signed in — confirm the session
      persists and no re-login is required
- [x] 5.4 Sign out — confirm the app returns to `LoginView` and all existing local
      class/schedule/session data remains intact
