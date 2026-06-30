## Context

The app currently models classes purely as *definitions*: a `TrainingClass` (id, name) owns a set of weekly recurring `ScheduleEntry` slots (`dayOfWeek` 1–7, `startHour`, `startMinute`). There is no representation of a class actually happening on a specific date. The existing UI is a single `NavigationStack` rooted in `ContentView` (a placeholder landing screen) with a gear-icon route into `SettingsView` for class/schedule CRUD. SwiftData is configured in `TrainingAssistantApp.swift` with `.modelContainer(for: [TrainingClass.self, ScheduleEntry.self])`, mirrored as `inMemory: true` containers in every `#Preview`.

This change adds the concept of running a class. The constraint that shapes most decisions: a `ScheduleEntry` is a *recurring weekly template*, not a dated event, so "the classes for today" must be **computed**, while a *started* class must be **persisted** so it can be reopened and later carry participants/attendance.

## Goals / Non-Goals

**Goals:**
- Introduce a persisted `ClassSession` representing one dated occurrence of a class.
- Compute today's candidate occurrences from the recurring schedule and list them.
- Let the user filter between not-yet-started occurrences and already-started sessions.
- Create-or-open a session on tap, with a guarantee of no duplicate session per occurrence.
- Show a concise read-only class summary and an empty participants placeholder.

**Non-Goals:**
- Any member / dog / attendee model or actual participant data (later change) — the participants list is an intentional empty placeholder.
- Editing or cancelling a session, session history/archiving, or notifications.
- Multi-day planning or a calendar/date-picker view; scope is the current day.
- Changing the existing `class-management` / `class-scheduling` behavior.

## Decisions

### Decision: A new persisted `ClassSession` model, distinct from `ScheduleEntry`

`ScheduleEntry` stays a pure recurring template. A new `@Model ClassSession` records an instantiated occurrence:
- `id: UUID`
- `date: Date` — the calendar day the session belongs to (normalized to start-of-day).
- `trainingClassID: UUID` / `scheduleEntryID: UUID` — identity of the originating definition and slot, stored as plain values rather than relationships.
- `name: String` — the session's display name, defaulted on start to `YY/MM/dd <class name>` (e.g. `26/06/30 Puppy Class`) so it reads sensibly and can be edited independently later.
- `className`, `dayOfWeek`, `startHour`, `startMinute` — a snapshot of the definition for the read-only summary.
- `init(...)`.

Decision: the session is a **self-contained snapshot**, not a graph of live relationships. The first implementation used `@Relationship var trainingClass`/`scheduleEntry` (no inverse). That proved unsafe: without an inverse SwiftData never nullifies the reference when the target is deleted, so a session could hold a dangling `ScheduleEntry`, and reading `scheduleEntry?.id` during list rendering crashed with *"backing data could no longer be found"*. Storing ids + a snapshot removes the relationship graph entirely — matching is by `UUID` (which can never fault), the summary is stable even if the definition is later edited or removed, and there are no inverse-inference or cascade-delete surprises. The cost is that the summary no longer auto-updates when the definition changes, which is acceptable (and arguably desirable) for a record of something that happened.

Register `ClassSession.self` in the `modelContainer(for:)` array and in every preview container. Every stored property carries a default value, which keeps the model lightweight-migration-safe as it evolves (a missing default makes an existing store fail to migrate, which silently breaks all saves).

### Decision: Opening is read-only; starting is explicit

Tapping an occurrence opens a detail view but does **not** create a session. The detail view shows the concise definition; when no session exists it offers a "Start Session" button that creates and persists the `ClassSession` and transitions the view in place to the started state. This replaces the earlier "tap creates-or-opens" behavior — creating a record as a side effect of navigation was both surprising and (when done in an eagerly-built `NavigationLink` destination) the source of an insert-during-render crash. Navigation now uses value-based `NavigationLink(value: occurrence)` + `navigationDestination(for: Occurrence.self)`, which is lazy, so no work happens until the user actually drills in.

### Decision: Occurrences are computed, sessions are queried; identity is (class, slot, date)

An "occurrence" is an in-memory value, not a model: `(trainingClass, scheduleEntry, date)` for slots whose `dayOfWeek` equals today's Calendar weekday. The list view:
1. `@Query`s all `TrainingClass` (with their schedule) and all `ClassSession` for today.
2. Builds today's occurrences from the schedule.
3. Marks each occurrence started/not-started by matching an existing `ClassSession` on the same `scheduleEntryID` (and date).

A session's uniqueness key is the originating slot plus the day; matching on `scheduleEntryID` + `date` is sufficient because each slot is at most one occurrence per day. Because a session is only created via the explicit "Start Session" action on an occurrence that has no session, and the detail view transitions to the started state once created, an occurrence yields at most one `ClassSession`.

### Decision: Scope to the current day, filter via a segmented `Picker`

The screen targets "today". A segmented `Picker` (in a small `enum` filter state) toggles between **To start** (occurrences with no session) and **Started** (occurrences with a session). This directly maps the user's "classes about to start / should have started" vs "instantiated classes" distinction and is the idiomatic SwiftUI choice for a small mutually-exclusive set. Rows are ordered by `startMinuteOfDay`. Each row may surface a lightweight timing hint (e.g. overdue vs upcoming relative to now) derived from the slot time, but timing does not gate creation — any of today's occurrences can be started.

Alternative considered: a date picker / week view. Deferred as a non-goal; today-only keeps the first cut focused.

### Decision: Views follow existing conventions

New files under `Views/`, matching the `<Thing>View` naming:
- `TodayClassesView` (or `ClassSessionsView`) — the list with the filter `Picker`, empty states via `ContentUnavailableView`, and a private row subview.
- `ClassSessionView` — the detail screen: a `Form`/`List` with a definition summary section (name, `Weekday.displayName`, `startTimeDisplay` reused from `ScheduleEntry`) and an empty participants section.

Navigation: add a `NavigationLink`/route from `ContentView`'s landing screen into the list; the list pushes the detail. Reuse `ScheduleEntry`'s existing computed helpers (`weekday`, `startTimeDisplay`) for the summary instead of re-deriving.

## Risks / Trade-offs

- **Referencing the live definition rather than snapshotting** → if a class/slot is edited or deleted after a session exists, the session's summary changes or the relationship nullifies. Acceptable now (no participant data is lost since there is none); revisit with a snapshot when attendance lands.
- **App-side duplicate prevention (no DB uniqueness)** → a race could in principle create two sessions for one occurrence. Single-user on-device app with synchronous taps makes this negligible; mirrors the existing schedule-entry approach.
- **"Today" derived from device clock / Calendar** → must use the same `Calendar` weekday convention (1 = Sunday) already used by `ScheduleEntry.dayOfWeek` to avoid off-by-one matching bugs.
