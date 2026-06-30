## Why

The app can define training classes and their weekly recurring schedule, but there is no way to actually *run* one. A trainer needs to open the app at (or near) a scheduled time, see which classes are due to start, and start one — turning the recurring definition into a concrete, dated session they can work with. This is the first step toward tracking what happens in a class (participants, attendance) in later changes.

## What Changes

- Introduce a concrete **class session**: a dated instance of a `TrainingClass`, derived from the class definition and one of its `ScheduleEntry` slots.
- Add a **"Classes" / today screen** (reachable from the landing screen) that lists candidate occurrences computed from the weekly schedule for the relevant day, alongside sessions that have already been started.
- Provide a **filter** on that screen to switch between occurrences that are *upcoming / about to start / overdue* (not yet instantiated) and classes that are *already started* (instantiated sessions).
- **Tapping an entry opens its session** — opening the existing session if one already exists for that occurrence, or creating a new session from the definition + schedule slot on first tap.
- Add a **session detail view** showing a concise read-only summary of the class definition (name, day, start time) and a **participants list that is empty for now** (placeholder; population is a later change).
- Register the new session model in the SwiftData `ModelContainer`.

## Capabilities

### New Capabilities
- `class-sessions`: Instantiating and opening a concrete session from a class definition and its weekly schedule — computing candidate occurrences for a day, listing and filtering them by started/not-started, the create-or-open behavior, and the session detail view (concise definition + placeholder participants list).

### Modified Capabilities
<!-- No published specs exist in openspec/specs/ yet; class-management and class-scheduling
     live in the in-flight training-schedule-settings change and are not being changed here. -->

## Impact

- **New model**: `ClassSession` (SwiftData `@Model`) referencing `TrainingClass` and the originating `ScheduleEntry`, with a session date.
- **Schema**: add `ClassSession.self` to the `.modelContainer(for:)` array in `TrainingAssistantApp.swift` and to every in-memory preview container.
- **New views**: a sessions/today list screen with a filter control, and a session detail screen — following the existing `Views/` layout and `<Thing>View` naming.
- **Navigation**: add an entry point from `ContentView` (the current landing screen) into the new sessions list.
- **No member/attendee model yet** — the participants list is an intentional empty placeholder; no existing capabilities change.
