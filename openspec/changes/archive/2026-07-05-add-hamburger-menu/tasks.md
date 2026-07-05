## 1. Extract the Classes screen

- [x] 1.1 Create `TrainingAssistant/Views/ClassesView.swift` by moving the `Section("Classes")` content out of `SettingsView`: `@Query` class list sorted by name, empty state, rows pushing `ClassEditorView`, swipe-to-delete (including schedule-entry cascade), add-class alert with non-empty + unique-name validation, and the "Add Class" (+) toolbar button; `navigationTitle` "Classes"
- [x] 1.2 Slim `SettingsView` down to a hub: replace the inline class list with `NavigationLink("Classes") { ClassesView() }` alongside the existing Club/Members link; keep Sign Out; remove the now-unneeded add-class state/toolbar from Settings
- [x] 1.3 Update/add `#Preview` for `ClassesView` (in-memory container registering all models) and fix the `SettingsView` preview

## 2. Hamburger menu component

- [x] 2.1 Add `MenuDestination` enum (`members`, `classes`; `Identifiable`) and an `appMenuToolbar()` view extension that owns the `@State` selection, adds a `.topBarLeading` `ToolbarItem` with a `Menu` (icon `line.3.horizontal`, entries "Members" and "Classes"), and attaches `.navigationDestination(item:)` mapping to `MembersView()` / `ClassesView()`
- [x] 2.2 Apply `appMenuToolbar()` to `ContentView` (landing), `TodayClassesView`, and `SessionHistoryView`; keep the existing gear/Settings toolbar item on the landing screen

## 3. Vocabulary

- [x] 3.1 Add a `## Vocabulary` section to `AGENTS.md`: "Classes" = class definitions/schedules, "Class Sessions" = dated started occurrences; never "Class Definitions" in UI or code
- [x] 3.2 Sweep user-facing strings and new identifiers in the change for the term "Class Definitions" and rename to "Classes"

## 4. Verification

- [x] 4.1 Build the app and run existing tests
- [x] 4.2 Verify in the simulator: menu present on landing, Today's Classes, and Session History; Members and Classes each push in one tap; Back returns to the originating screen; landing → Today → menu → Members works (no duplicate-destination issues)
- [x] 4.3 Re-verify class-management scenarios on `ClassesView`: create (valid/blank/duplicate), rename, delete cascades schedule entries, empty state; confirm Settings shows Classes + Members entries and Sign Out still works
