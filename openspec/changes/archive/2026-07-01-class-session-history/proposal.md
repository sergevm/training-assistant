## Why

Trainers can now start a class session for the current day, but once a day passes there is no way to look back at what happened. Sessions are persisted, yet the only screen that surfaces them — `TodayClassesView` — is scoped to today's schedule, so yesterday's (and every earlier) session becomes invisible. A trainer needs a running record of the classes they have held, most-recent first, and a way to reopen any one of them. This is also the natural home for per-session data (participants, attendance, notes) that later changes will attach to a session.

## What Changes

- Add a **history entry point** on the landing screen (`ContentView`), alongside the existing "Today's Classes" button, that navigates to a new session-history screen.
- Add a **Session History screen** listing **every** started `ClassSession`, newest first.
- **Group the list by calendar date**, with date section headers ordered descending (most recent day first); sessions within a day are ordered by start time.
- Show an **empty state** when no sessions have ever been started.
- **Tapping a session opens its detail** — reusing the existing read-only session detail (name, day, start time, participants placeholder), rendered from the session's own stored snapshot so it works even if the originating class or schedule slot was later edited or deleted.

## Capabilities

### Modified Capabilities
- `class-sessions`: Adds session history — a landing-screen entry point to a screen that lists all started sessions grouped by date (descending) and opens each session's existing detail view. The `class-sessions` capability already owns session instantiation, the today list, and the session detail view; history extends how persisted sessions are surfaced.

## Impact

- **New view**: `Views/SessionHistoryView.swift` — a `@Query` over all `ClassSession`s sorted by `date` descending, grouped into date sections, following the existing `Views/` layout and `<Thing>View` naming.
- **Navigation**: add a second entry point in `ContentView` into the history screen (no change to the existing Today's Classes route).
- **Session detail reuse**: the detail must be reachable from a persisted `ClassSession` (using its snapshot), not only from a live `Occurrence`. Expect either a session-based initializer on the existing detail view or a thin adapter that builds the summary from the snapshot — see design.
- **No model changes**: `ClassSession` already stores everything the list and detail need (`date`, `name`, `className`, `dayOfWeek`, `startHour`, `startMinute`). No schema migration.
- **No new participant data** — the participants section stays the existing empty placeholder.
