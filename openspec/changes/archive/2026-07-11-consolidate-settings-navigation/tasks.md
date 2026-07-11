## 1. Consolidate the app menu

- [x] 1.1 In `AppMenu.swift`, move the menu's `ToolbarItem` placement from `.topBarLeading` to `.topBarTrailing`
- [x] 1.2 Add a `Divider()` and a destructive Sign Out `Button` (icon `rectangle.portrait.and.arrow.right`) below the Members/Classes shortcuts in the menu
- [x] 1.3 Give `AppMenuToolbar` `@Environment(AuthService.self)` and a `showsSignOutConfirmation` state; move the confirmation dialog (same title, message, and buttons as `SettingsView`'s) into the modifier, calling `AuthService.signOut()` on confirm

## 2. Remove the Settings screen

- [x] 2.1 Remove the gear `ToolbarItem` (and its `SettingsView` push) from `ContentView.swift`
- [x] 2.2 Delete `TrainingAssistant/Views/SettingsView.swift` and remove any lingering references (Xcode project entry, previews, comments pointing users to Settings)
- [x] 2.3 Update the landing screen's onboarding copy in `ContentView` ("…in Settings.") to point at the menu instead

## 3. Verify

- [x] 3.1 Add `.environment(AuthService())` to the previews of every screen using `appMenuToolbar()` (landing, Today's Classes, Session History) so they still render
- [x] 3.2 Build and run: confirm the menu sits top right on all three primary screens, Members/Classes push correctly, and no gear button remains
- [x] 3.3 Exercise sign-out from the menu on a non-landing screen: confirm the dialog appears, cancel keeps the session, confirm shows the login screen (login-screen transition not observable in simulator Debug builds — `isSignedIn` is hard-wired true there; needs a device build to observe)
