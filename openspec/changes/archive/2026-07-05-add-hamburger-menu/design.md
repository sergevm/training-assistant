## Context

The app has a single production `NavigationStack`, rooted in `ContentView`
(landing screen). Every other screen is pushed onto it: `TodayClassesView`,
`SessionHistoryView`, and `SettingsView` (via a gear toolbar button).
`MembersView` is reached through Settings, and the class list is not a view of
its own — it lives inline as `Section("Classes")` inside `SettingsView`, with
`ClassEditorView` as the per-class detail and an "Add Class" (+) toolbar button
on Settings.

The user wants Members and Classes reachable in one tap from the app's primary
screens. Per the accepted proposal: a native toolbar dropdown `Menu` behind a
hamburger icon, containing **Members** and **Classes**; terminology is
"Classes" / "Class Sessions", never "Class Definitions".

Constraints from `CLAUDE.md`:
- Row → detail pushes are driven by `@State` selection +
  `.navigationDestination(item:)`, never by pushing a `@Model` as a path value.
- Full-row tappability pattern for plain-button rows.

## Goals / Non-Goals

**Goals:**
- One-tap access to Members and Classes from the landing screen, Today's
  Classes, and Session History.
- A standalone Classes screen (list + add + empty state) extracted from
  `SettingsView`, so the menu and Settings share one destination.
- A single reusable menu component so the three host screens don't duplicate
  toolbar/menu/navigation wiring.
- Record the Classes / Class Sessions vocabulary in `AGENTS.md`.

**Non-Goals:**
- No slide-out drawer, no `TabView`, no restructuring of the navigation stack
  into a path-based root.
- The menu does not replace the Settings gear; Settings remains the home of
  Sign Out and still links to Members and Classes.
- No menu on deep/detail screens (session detail, editors, sheets) — those keep
  their focused toolbars.
- No model or persistence changes.

## Decisions

### D1: Native toolbar `Menu`, not a custom drawer

A `ToolbarItem(placement: .topBarLeading)` hosting a SwiftUI `Menu` with a
`line.3.horizontal` ("hamburger") icon. Chosen by the user over a slide-out
drawer. Rationale: idiomatic iOS, zero custom gesture/overlay code, and it
composes with the existing single `NavigationStack` — a drawer would have
required converting the root to a path-based stack to jump destinations, which
conflicts with the project's item-based navigation convention.

### D2: One shared component — enum destination + view modifier

A `MenuDestination` enum (`members`, `classes`; `Identifiable` via `self`) and a
small view extension, e.g. `.appMenuToolbar()`, that each host screen applies
once. The modifier:

1. owns `@State private var menuSelection: MenuDestination?`,
2. adds the hamburger `ToolbarItem` whose `Menu` sets the selection, and
3. attaches `.navigationDestination(item: $menuSelection)` mapping
   `.members → MembersView()`, `.classes → ClassesView()`.

This follows the CLAUDE.md selection-state pattern (the enum is a value type,
so it is safe as a destination item) and keeps `ContentView`,
`TodayClassesView`, and `SessionHistoryView` to a one-line change each.

Alternative considered: repeating the toolbar + destination wiring in each
screen — rejected as three copies of identical state and mapping.

### D3: Pushes ride the current stack; no stack reset

Selecting Members while on Session History pushes `MembersView` on top of
History. Back returns to where the user was. This is deliberate: the menu is a
shortcut, not a root switcher, and it avoids any path manipulation of the
shared stack. `MembersView` already works when pushed from anywhere inside the
stack (it has no own `NavigationStack` outside previews); `ClassesView` will be
built the same way.

### D4: Extract `ClassesView` from `SettingsView`

New `ClassesView` takes over, verbatim, what `Section("Classes")` in
`SettingsView` does today: `@Query` class list ordered by name, empty state,
add-class alert with validation (non-empty, unique), rows pushing
`ClassEditorView`, swipe-to-delete, and the "Add Class" (+) toolbar button
(which moves from Settings to this screen). `SettingsView` replaces the inline
section with a `NavigationLink("Classes") { ClassesView() }` alongside the
existing Members link — Settings becomes a simple hub (Club/Members, Classes,
Sign Out).

Alternative considered: menu navigates to `SettingsView` — rejected; it defeats
the one-tap purpose and keeps Classes two levels deep.

### D5: Terminology

User-facing strings and identifiers say **Classes** (`ClassesView`, menu label
"Classes") and **Class Sessions** for dated started occurrences. `AGENTS.md`
gains a `## Vocabulary` section defining both terms and proscribing "Class
Definitions".

## Risks / Trade-offs

- [Duplicate `navigationDestination(item:)` registrations if a host screen is
  pushed from another host (e.g. landing → Today, both carrying the modifier)]
  → Each modifier instance owns a distinct `@State`, and SwiftUI resolves the
  destination against the nearest registration; verify by navigating
  landing → Today → menu → Members in the simulator/tests.
- [Behavioral drift while extracting the class list from `SettingsView`
  (validation, delete-cascade, empty state)] → Move the code, don't rewrite it;
  the existing `class-management` scenarios (create/rename/duplicate/delete)
  are re-verified on `ClassesView` after the move.
- [Menu on only three screens may read as "not truly global"] → Accepted: deep
  screens keep focused toolbars; every primary screen the user parks on has the
  menu, and Settings itself already links to both destinations.
- [Two entry points to the same screens (menu + Settings) could push two
  instances] → Fine within one stack; each push is independent and Back unwinds
  normally.

## Migration Plan

Pure additive UI refactor in one PR: add `MenuDestination` + modifier + `ClassesView`,
slim down `SettingsView`, apply the modifier to the three hosts, update `AGENTS.md`.
Rollback = revert the PR; no data or schema impact.

## Open Questions

None — menu style and naming were settled with the user; menu contents default
to Members + Classes with the gear/Settings hub retained.
