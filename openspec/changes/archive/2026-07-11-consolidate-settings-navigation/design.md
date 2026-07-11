## Context

`AppMenu.swift` provides an `appMenuToolbar()` view modifier that installs a
hamburger `Menu` at `.topBarLeading` on the landing screen, Today's Classes, and
Session History, with Members and Classes shortcuts driven by
`@State` + `.navigationDestination(item:)`. Separately, `ContentView` installs a
gear button at `.topBarTrailing` that pushes `SettingsView`, which duplicates
the same two entries and hosts the Sign Out button with its confirmation
dialog. `AuthService` is injected at the app root via
`.environment(AuthService.self)`.

## Goals / Non-Goals

**Goals:**
- One navigation menu, placed at the top-right (trailing) position on every
  primary screen.
- Sign Out remains available, with its existing confirmation dialog, now inside
  the menu.
- `SettingsView` and the gear button disappear.

**Non-Goals:**
- No new settings/preferences content. If a real settings screen is needed
  later, it can be reintroduced as a menu entry.
- No change to sign-out semantics (`AuthService.signOut()`, data stays on
  device) or to the login flow.
- No changes to the Members/Classes screens themselves.

## Decisions

- **Move the menu to `.topBarTrailing` inside `AppMenuToolbar`.** One-line
  placement change; all three primary screens pick it up from the shared
  modifier, which is exactly why the modifier exists. `ContentView` drops its
  own gear `ToolbarItem`.
- **Sign Out is a plain destructive `Button` in the menu, not a
  `MenuDestination` case.** `MenuDestination` models push-navigation targets;
  sign-out is an action, not a destination. A `Divider()` separates the
  navigation shortcuts from the destructive action, matching platform
  convention.
- **The confirmation dialog moves into `AppMenuToolbar`.** The modifier gains
  `@Environment(AuthService.self)` and a `showsSignOutConfirmation` state, and
  reuses the existing dialog copy verbatim ("Your classes and schedule stay on
  this device."). This keeps sign-out available from all primary screens, not
  just the landing screen. Alternative considered: keep the dialog in
  `ContentView` — rejected because the menu (and thus the trigger) lives on
  three screens.
- **Delete `SettingsView.swift`.** After the move it would contain nothing.

## Risks / Trade-offs

- [Every screen using `appMenuToolbar()` now requires `AuthService` in the
  environment] → It is already injected at the app root; previews for
  `TodayClassesView` and `SessionHistoryView` must add
  `.environment(AuthService())` or they crash.
- [A destructive action adjacent to navigation shortcuts risks accidental taps]
  → Divider separation, `role: .destructive` styling, and the existing
  confirmation dialog gate the action.
- [Sign Out was only on the landing screen; now it is on three screens] →
  Intentional; the confirmation dialog is unchanged, semantics identical.
