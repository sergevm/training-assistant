## Why

TrainingAssistant is currently a fully local, single-user app with no concept of an
account. It needs to become a multi-user app where new users must be invited before
they can create an account, and where sign-in happens through Apple or Google rather
than an app-managed password. This is needed now because the app is
moving from "one trainer's local device" toward supporting multiple trainers, and
account creation must stay invite-gated rather than open to the public from day one.

## What Changes

- Introduce Supabase as the app's backend for authentication (Postgres + Auth). This is
  the project's first backend dependency and first external SPM package.
- Add sign-in with Apple (native, `AuthenticationServices` + Supabase ID-token flow)
  and Google (Supabase OAuth web flow). Apple is included because Apple App Store
  Review Guideline 4.8 requires it whenever other third-party social sign-in options
  are offered. Facebook is deferred (see design.md Non-Goals) and can be added later
  as a thin additive change.
- Restrict account creation to invited users only: a Supabase "Before User Created"
  Auth Hook checks the signing-up email against an `invited_users` allowlist table and
  rejects the signup (any provider) if the email isn't present. Invites are added to
  that table manually via the Supabase dashboard for v1 — no in-app invite UI yet.
- Add an `AuthService` that tracks the current session and exposes sign-in/sign-out,
  and gate the app's existing root content behind it: signed-out users see a new
  `LoginView`; signed-in users see today's `ContentView` unchanged.
- **BREAKING** (behavioral, not data): the app can no longer be used without
  successfully signing in. All existing local SwiftData content (classes, schedules,
  sessions) is unaffected and remains fully local — only app *access* is gated.

## Capabilities

### New Capabilities
- `user-authentication`: invite-gated account creation and sign-in via Apple or
  Google, session persistence across launches, and sign-out, implemented via
  Supabase Auth.

### Modified Capabilities
(none — existing `class-management`, `class-scheduling`, and `class-sessions`
capabilities are unaffected; this change only adds a new gate in front of the app,
not new requirements on those capabilities)

## Impact

- **New dependency**: `supabase-swift` (Auth module) added via Swift Package Manager —
  the project's first external SPM package.
- **New external service**: a Supabase project (Postgres + Auth), configured with
  Apple/Google providers and an `invited_users` allowlist table + Before User
  Created hook. This setup lives outside the repo (Supabase dashboard) and is a
  prerequisite for testing this change, not something coded in this repo.
- **Xcode project**: adds the "Sign in with Apple" capability (system framework, no new
  dependency).
- **New files**: `AuthService`, `RootView`, `LoginView`.
- **Changed composition root**: `TrainingAssistantApp.swift` gains `.environment(authService)`
  alongside the existing `.modelContainer(container)`, and the scene's root content
  changes from `ContentView` directly to the new `RootView`.
- **No SwiftData schema changes**: no new `@Model` types; Supabase owns the user store
  and local class/session data remains fully local and un-scoped to a user for now
  (explicitly flagged as an out-of-scope follow-up in design.md).
