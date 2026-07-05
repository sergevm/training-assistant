# Add Hamburger Menu

## Why

Members and Classes are the two most-visited management screens, but today they sit
two to three levels deep behind the Settings gear (Settings → Members, Settings →
inline class list). A hamburger menu on the app's primary screens makes both
destinations reachable in one tap from wherever the user is working.

## What Changes

- Add a hamburger menu (native toolbar dropdown `Menu` behind a `☰` icon) to the
  primary screens: the landing screen, Today's Classes, and Session History.
- The menu offers two navigation shortcuts: **Members** and **Classes**. Selecting
  one pushes the corresponding screen onto the current navigation stack.
- Extract the class list from `SettingsView` into a dedicated **Classes** screen so
  the menu has a standalone destination; Settings links to it instead of embedding
  the list. Members management is unchanged and stays reachable from Settings too.
- Standardize terminology: the app says **Classes** (definitions/schedules) and
  **Class Sessions** (dated, started occurrences) — never "Class Definitions".
  Record this vocabulary in `AGENTS.md`.

## Capabilities

### New Capabilities

- `app-navigation`: global navigation affordances — the hamburger menu, which
  screens carry it, what it contains, and how selection navigates.

### Modified Capabilities

- `class-management`: the class list moves from an inline section of the Settings
  screen to a dedicated Classes screen; the Settings entry-point requirement changes
  to "Settings provides an entry to the Classes screen" rather than "Settings shows
  the list of classes".

## Impact

- **Views**: `ContentView.swift`, `TodayClassesView.swift`,
  `SessionHistoryView.swift` gain the menu toolbar item; `SettingsView.swift` loses
  the inline class list; new `ClassesView.swift` (extracted list) and a small shared
  menu component.
- **Navigation**: pushes ride the existing single `NavigationStack`, using the
  established `@State` selection + `.navigationDestination(item:)` pattern.
- **Docs**: `AGENTS.md` gains a Vocabulary section (Classes vs. Class Sessions).
- No model, persistence, or auth changes.
