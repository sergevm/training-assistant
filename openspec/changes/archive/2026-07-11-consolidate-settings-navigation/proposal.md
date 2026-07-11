## Why

The landing screen currently offers two overlapping navigation entry points: a
hamburger menu (top left) with Members and Classes shortcuts, and a gear button
(top right) that opens a Settings screen whose only content is… the same two
entries, plus Sign Out. The duplication is confusing, and the menu placement is
inconsistent with the gear. One menu, in one consistent location, should carry
all of it.

## What Changes

- **BREAKING (UI)**: Remove the Settings screen (`SettingsView`) and the gear
  toolbar button entirely. Members and Classes are reachable only via the app
  menu.
- Move the hamburger menu from the leading (top-left) to the trailing
  (top-right) navigation-bar position, at the same position on every primary
  screen (landing, Today's Classes, Session History).
- Add a destructive **Sign Out** entry to the hamburger menu, separated from the
  navigation shortcuts. It reuses the existing confirmation dialog before
  calling `AuthService.signOut()`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `app-navigation`: menu placement becomes trailing (top right) on all primary
  screens; the menu gains a destructive Sign Out entry with confirmation.
- `class-management`: the "Settings entry point" requirement is removed; the
  Classes screen is reachable from the hamburger menu only.
- `club-membership`: the Club/Members entry point moves from Settings to the
  hamburger menu.

## Impact

- `TrainingAssistant/Views/AppMenu.swift` — placement change, Sign Out entry,
  confirmation dialog, `AuthService` dependency.
- `TrainingAssistant/ContentView.swift` — gear toolbar item removed.
- `TrainingAssistant/Views/SettingsView.swift` — deleted.
- `user-authentication` spec is unaffected: it requires an explicit sign-out
  trigger without prescribing where it lives; only the entry point moves.
