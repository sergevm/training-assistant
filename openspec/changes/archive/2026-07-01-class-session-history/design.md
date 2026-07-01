## Context

`ClassSession` is a persisted, self-contained snapshot of a class that was started on a specific date (`id`, `date` normalized to start-of-day, `trainingClassID`/`scheduleEntryID` for identity, plus `name` and a `className`/`dayOfWeek`/`startHour`/`startMinute` snapshot of the definition). It deliberately holds **ids + a snapshot rather than live relationships**, so a session survives edits or deletion of its originating `TrainingClass`/`ScheduleEntry` (see the start-class design — live relationships without an inverse caused "backing data could no longer be found" crashes).

Today, sessions are only surfaced through `TodayClassesView`, which computes occurrences from the recurring schedule for the current weekday. Nothing lists sessions from earlier days. This change adds a history screen that reads persisted sessions directly, independent of the schedule.

The existing detail view, `ClassSessionView`, is built around a live `Occurrence(trainingClass:scheduleEntry:date:session:)` and derives a *live* `@Query` keyed on `scheduleEntry.id` to decide whether a session exists and to render the "Start Session" affordance. History has no live `Occurrence` to hand it — and the originating slot may no longer exist — so reuse needs care.

## Goals / Non-Goals

**Goals:**
- List **every** started `ClassSession`, newest first, reachable from the landing screen.
- Group the list by calendar date with descending date headers.
- Open a session's existing read-only detail from a history row.
- Render both the list and the reopened detail purely from the session's stored snapshot, so history is correct even after the originating class/slot changes or is deleted.

**Non-Goals:**
- Editing, renaming, or deleting sessions from history (later change).
- Filtering/searching history, date-range pickers, or calendar views.
- Any participant/attendance data — the participants section stays the existing empty placeholder.
- Changing how sessions are created or how `TodayClassesView` behaves.

## Decisions

### Decision: A dedicated history screen driven by a direct `@Query` over sessions

`SessionHistoryView` uses `@Query(sort: \ClassSession.date, order: .reverse)` to fetch all sessions, then groups them into date buckets in Swift (keyed by `Calendar.current.startOfDay(for:)`), emitting one `List` `Section` per day with the day as its header. Groups are ordered by date descending; rows within a group by `startHour`/`startMinute`.

Grouping in Swift (rather than via the query) keeps the day-bucketing logic explicit and avoids relying on `#Predicate`/`SortDescriptor` date semantics across the in-memory→store round-trip, which the start-class work already found unreliable. Each row shows the session `name` (which already encodes `YY/MM/dd <class name>`); the section header carries the human-readable date, and the row can additionally show the start time so multiple sessions on one day are distinguishable.

### Decision: Reopen the detail from the `ClassSession` snapshot, not a live `Occurrence`

A history row must open the same read-only summary a started session shows today, but it cannot assume the originating `TrainingClass`/`ScheduleEntry` still exist. So the detail path for history is driven by the **session snapshot**, not by reconstructing a live `Occurrence`.

Preferred approach: give `ClassSessionView` a second, session-based entry point (e.g. `init(session: ClassSession)`) that renders the summary — name, day (`Weekday(rawValue: dayOfWeek)?.displayName`), start time (formatted from `startHour`/`startMinute`) — from the snapshot, and always shows the started state (participants placeholder, no "Start Session" button, since a session in history is by definition already started). The existing occurrence-based initializer stays for the today flow.

This keeps a single detail view for both flows while removing history's dependence on live relationships. If splitting the view proves cleaner than branching its state, a thin `SessionDetailView` that renders the snapshot is an acceptable alternative; either way the requirement is: **history detail renders from the stored snapshot and works when the origin class/slot is gone.**

Navigation uses `@State` selection + `.navigationDestination(item:)`, mirroring `TodayClassesView`. A value-based path (`NavigationLink(value: session)` + `navigationDestination(for: ClassSession.self)`) was tried first but **loops**: `ClassSession` is a SwiftData `@Model` (reference type), and pushing it as a `NavigationStack` path value re-triggers the push endlessly. Driving the push from a `@State private var selectedSession: ClassSession?` set by a plain `Button` row avoids the path machinery entirely and matches the pattern already proven in the today flow.

### Decision: History includes today's sessions

History lists all started sessions, including any started today. Today's sessions therefore appear both here and (as "started" occurrences) in `TodayClassesView`; that overlap is intended — history is the complete record, the today screen is the live working surface. No date cutoff is applied.

## Risks / Trade-offs

- **Detail-view reuse vs. duplication** — adding a session-based path to `ClassSessionView` risks tangling two rendering modes in one view. Mitigation: the snapshot path is strictly simpler (always-started, no mutation), so it can be a small, clearly separated branch or an extracted subview; escalate to a separate `SessionDetailView` only if branching gets awkward.
- **Unbounded list growth** — history grows without bound over time. Acceptable for now; a school's session volume is low and `@Query` + `List` are lazy. Pagination/archiving is a later concern if it ever matters.
- **Snapshot staleness** — a renamed class won't retroactively update past session summaries. This is the intended, already-established behavior for `ClassSession` (a record of what happened), not a regression.

## Migration

None. `ClassSession` already carries every field the history list and snapshot-based detail need; no schema change, no data migration.
