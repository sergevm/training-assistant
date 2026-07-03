## Context

TrainingAssistant is a SwiftUI + SwiftData app with zero external dependencies today:
no networking, no `User`/`Account` model, a single `NavigationStack` root
(`ContentView`) wired up in `TrainingAssistantApp.swift` with only a `ModelContainer`
attached. This change adds the app's first backend dependency (Supabase) and its first
gate on app access.

The driving constraint is invite-only account creation: signup must be rejected for
anyone not pre-approved, regardless of which identity provider (Apple, Google) they
sign up through. Verified against current Supabase docs: the "Before
User Created" Auth Hook fires for every signup path — its payload includes
`user.app_metadata.provider` — so a single Postgres-function hook checking an
allowlist table gates all providers uniformly.

## Goals / Non-Goals

**Goals:**
- Gate the entire app behind a signed-in session; signed-out users only ever see a
  login screen.
- Support sign-in via Apple and Google.
- Enforce invite-only account creation across all providers via one server-side
  mechanism (not duplicated per-provider client-side logic, which would be
  bypassable).
- Persist the session across app launches (no re-login on every cold start).
- Keep the v1 dependency footprint minimal: one new SPM package (`supabase-swift`)
  plus Apple's system `AuthenticationServices` framework.

**Non-Goals:**
- No in-app invite-management UI (v1 invites are inserted directly into Supabase via
  the dashboard/SQL editor).
- No syncing of `TrainingClass`/`ScheduleEntry`/`ClassSession` data to Supabase, and no
  per-user ownership/scoping of that local data. All local SwiftData content remains
  local and shared across whoever is signed in on that device. Explicitly flagged for
  a future change if multi-trainer data separation is needed.
- No Facebook sign-in in v1 — descoped to keep the launch surface small. The
  `AuthService` browser-OAuth path is provider-generic, so Facebook can be added later
  as a purely additive change (enable the Supabase provider + a thin
  `signInWithFacebook()` wrapper + a login button), with no redesign.
- No native Google Sign-In SDK (`GoogleSignIn-iOS`) integration in v1 — Google goes
  through Supabase's browser-based OAuth flow instead. Revisit as a v2 upgrade if the
  browser hop proves to be a poor UX.
- No password/email-based sign-in — social sign-in only.
- No account deletion, profile editing, or multi-factor auth in this change.

## Decisions

**Backend: Supabase over Firebase / Auth0 / CloudKit-only.**
Chosen because it bundles Postgres + Auth in one project (the allowlist table and the
Before User Created hook both live in the same Postgres instance, no separate service
to wire together), has a native Swift SDK with a first-class `signInWithIdToken` path
for Apple/Google, and — unlike a CloudKit-only approach — isn't limited to Apple
devices, leaving room for a future Android or web client against the same backend.

**Invite gating: server-side "Before User Created" Auth Hook, not a client-side check.**
A client-side "is this email invited?" check before calling `signUp` would be
trivially bypassable (nothing stops a client from skipping the check and calling the
Supabase API directly). The Auth Hook runs inside Supabase itself, ahead of user
creation, for every provider — this is the only point that can't be bypassed from the
client.

**Apple: native ID-token flow. Google: Supabase OAuth (browser) flow.**
Apple sign-in is required regardless (App Store Guideline 4.8) and its native flow
(`ASAuthorizationController` → `supabase.auth.signInWithIdToken`) needs no extra
dependency beyond the system `AuthenticationServices` framework, so there's no reason
not to use the better native UX there. Google's native SDK (`GoogleSignIn-iOS`) would
add a new dependency and new per-provider console configuration (URL schemes, reversed
client IDs) for a UX improvement (avoiding one browser hop) that isn't essential for
v1. Supabase's built-in `signInWithOAuth(provider:)` via `ASWebAuthenticationSession`
covers Google with the `supabase-swift` package alone.

**Session/state management: a single `AuthService` (`@Observable`) as the source of
truth, driven by `supabase.auth.authStateChanges`.**
Mirrors this app's existing preference for local `@State`-driven UI (see CLAUDE.md
navigation conventions) rather than introducing a heavier state-management framework.
`AuthService` is the one new environment-injected dependency, added the same way the
existing `ModelContainer` is injected today — no new DI pattern introduced.

**Root gating: new `RootView` in front of `ContentView`, not auth checks scattered
across views.**
`ContentView` and everything under it stays untouched. `RootView` becomes the scene's
actual root content and does a single branch: `authService.isSignedIn ? ContentView()
: LoginView()`. This keeps the blast radius of this change limited to
`TrainingAssistantApp.swift` + two new files, rather than threading auth state through
existing screens.

## Risks / Trade-offs

- **[Risk]** Browser-based OAuth (Google) is a visibly worse UX than native
  sign-in (a system sheet hands off to Safari). → **Mitigation**: acceptable for v1
  given no extra dependencies are required; documented as a deliberate, revisitable
  v2 upgrade in Non-Goals.
- **[Risk]** The Before User Created hook is configured entirely outside this repo (in
  the Supabase dashboard), so there's no automated test or code review for it — a
  misconfigured or disabled hook would silently allow open signup. → **Mitigation**:
  the manual verification steps in tasks.md explicitly test the reject-path (attempt
  signup with a non-invited email) as a launch gate, not just the happy path.
  Optionally, document the hook's SQL in this change's `design.md`/repo (as reference,
  even though it isn't deployed from the repo) so it's reviewable and reproducible if
  the Supabase project is ever rebuilt.
- **[Risk]** Local SwiftData content is not scoped per-user — if the device is ever
  shared between two invited trainers, they'd see each other's classes/sessions after
  each signs in. → **Mitigation**: explicitly out of scope per Non-Goals; acceptable
  because the app is currently used by a single trainer per device. Flagged as a
  follow-up change if multi-trainer, same-device usage becomes a real need.
- **[Trade-off]** No in-app invite UI means every invite requires manual Supabase
  dashboard access. → **Mitigation**: acceptable for the current small, trusted user
  base; a follow-up change can add an in-app "invite a trainer" flow once the core
  auth gate is proven.

## Migration Plan

1. Prerequisite (outside repo): create/configure the Supabase project — enable Apple
   and Google providers; create `invited_users` table; install the Before User
   Created hook; insert at least one invited email for testing.
2. Add `supabase-swift` SPM dependency and the "Sign in with Apple" capability to the
   Xcode project.
3. Implement `AuthService`, `LoginView`, `RootView`; wire `RootView` + `.environment(authService)`
   into `TrainingAssistantApp.swift` in place of `ContentView` as the scene's direct
   root content.
4. Manually verify all scenarios in `specs/user-authentication/spec.md` (reject
   non-invited signup across all providers, accept invited signup, session
   persistence across relaunch, sign-out).
5. No rollback complexity for existing users/data: this change adds a gate in front of
   the app but touches no existing SwiftData schema or content, so reverting is a plain
   code revert with no data migration to undo.

## Open Questions

- Should the `invited_users` allowlist match on email only, or also need to match the
  specific provider (e.g., an invite for `alice@example.com` via Google shouldn't
  necessarily also work via Apple)? Defaulting to email-only matching (provider-
  agnostic) for v1 simplicity; revisit if that proves too permissive.
- When should the follow-up "scope local data per signed-in user" change be
  prioritized? Left for a future proposal once real multi-trainer usage patterns are
  known.
