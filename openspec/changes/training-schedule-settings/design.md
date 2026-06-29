## Context

The app is a fresh iPhone-only iOS 26 SwiftUI project. `ContentView` is currently a placeholder. There is no persistence layer yet. This change introduces the first real feature — a Settings area for defining the school's classes and their weekly recurring schedules — and with it the app's first local data store. Because everything downstream (registering trainings, attendance, results) hangs off these class definitions, the data model and store choice made here matter beyond this change.

## Goals / Non-Goals

**Goals:**
- A Settings screen reachable from the main screen, with full create/edit/delete of classes.
- Per-class weekly schedule entries (day-of-week + start hour, fixed one-hour duration), supporting multiple entries per week and per day.
- On-device persistence that survives app restarts, with no third-party dependencies.
- A data model that is a sensible foundation for later "register a training" work.

**Non-Goals:**
- Registering, recording, or attending actual training sessions.
- Calendar/date-specific scheduling (entries are recurring weekly templates, not dated events).
- Variable class durations, capacity, instructors, enrolled dogs, or notifications.
- Sync, multi-device, or cloud backup.

## Decisions

### Persistence: SwiftData

Use **SwiftData** (built into iOS 26) as the local store, configured via `.modelContainer(for:)` on the `WindowGroup` and accessed in views through `@Environment(\.modelContext)` and `@Query`.

- *Why:* It is the native SwiftUI persistence framework, requires no dependencies, and its `@Query` integration keeps the class/schedule lists reactive with minimal code. The data set is tiny and single-user.
- *Alternatives considered:* Core Data directly (more boilerplate, older API surface); raw SQLite/GRDB (extra dependency, manual reactivity); plain JSON files (loses query/relationship support and grows awkward as the model expands toward trainings).

### Data model: `TrainingClass` and `ScheduleEntry`

Two `@Model` types with a one-to-many relationship:

- `TrainingClass`: `id` (UUID), `name` (String), `schedule` (`[ScheduleEntry]`, cascade delete).
- `ScheduleEntry`: `id` (UUID), `dayOfWeek` (Int, 1–7), `startHour` (Int, 0–23), `startMinute` (Int, one of 0/15/30/45), back-reference to its class.

Decisions:
- **Day of week stored as an Int** (1 = Sunday … 7 = Saturday, matching `Calendar` weekday convention) rather than an enum persisted directly, to keep the schema stable; a `Weekday` enum wraps it for display and pickers.
- **Start time stored as separate `startHour` (0–23) and `startMinute` Ints**, not a `Date`. The minute is constrained at the UI layer to a quarter-hour boundary (0/15/30/45). Duration is a fixed one hour and is not stored — it is implied. This avoids timezone/date ambiguity for a recurring weekly template; the time is rendered through the user's locale for display.
- **Quarter-hour granularity is enforced at the picker, not the schema.** The editor offers a single locale-formatted time picker whose options step every 15 minutes across the day, so out-of-grid minutes are never selectable. Storing hour+minute (rather than minutes-since-midnight) keeps the persisted fields human-readable and preserves the existing `startHour` field.
- **Cascade delete** on `TrainingClass.schedule` so deleting a class removes its entries (satisfies the class-management delete requirement).

### Duplicate prevention in app logic

Uniqueness of (`dayOfWeek`, `startHour`, `startMinute`) within a class is enforced in the view-model/insert path, not by a DB constraint — SwiftData's unique constraints don't cleanly express "unique within a parent relationship." The add action checks existing entries before inserting.

### Navigation & view structure

- `ContentView` → `NavigationStack` with a link/toolbar button into `SettingsView`.
- `SettingsView`: `@Query` list of classes, add button, swipe-to-delete, navigation into a class.
- `ClassEditorView`: edit name + list of schedule entries with add/remove.
- `ScheduleEntryEditorView`: day-of-week picker + start-hour picker.

## Risks / Trade-offs

- **Weekday integer convention drift** → Centralize the mapping in a single `Weekday` enum used everywhere; never hand-roll the Int↔label mapping in views.
- **Hour-as-Int display across locales** (12h vs 24h) → Render via `Date`/`DateFormatter` (or `.formatted`) at display time from the stored hour, so the UI respects locale without storing a date.
- **SwiftData schema evolution** as the app grows toward trainings → Keep models small and additive now; SwiftData lightweight migration covers added properties. Avoid premature fields.
- **Duplicate check is app-side, not enforced by the store** → Acceptable for a single-user local app; keep the check in one place (the insert path) to avoid divergence.

## Open Questions

- Should start hour be free-form per-class or constrained to the school's operating hours? Assumed free-form (0–23) for now; can tighten later.
- Should the main screen show anything besides the Settings entry point in this change? Assumed no — main screen just provides navigation into Settings until the trainings feature lands.
