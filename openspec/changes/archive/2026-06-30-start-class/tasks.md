## 1. Data model

- [x] 1.1 Create `Models/ClassSession.swift` — `@Model` with `id: UUID`, `date: Date`, `@Relationship var trainingClass: TrainingClass?`, `@Relationship var scheduleEntry: ScheduleEntry?`, and an initializer
- [x] 1.2 Register `ClassSession.self` in the `.modelContainer(for:)` array in `TrainingAssistantApp.swift`
- [x] 1.3 Add a computed occurrence-date helper (normalize a `ScheduleEntry` + reference date to start-of-day for the matching weekday) — colocated with the session/occurrence logic

## 2. Occurrence computation

- [x] 2.1 Define an `Occurrence` value type (`trainingClass`, `scheduleEntry`, `date`, `isStarted`) — not a model
- [x] 2.2 Implement logic to build today's occurrences: match each `ScheduleEntry.dayOfWeek` against today's `Calendar` weekday (1 = Sunday convention), one occurrence per matching slot
- [x] 2.3 Sort occurrences by `startMinuteOfDay`
- [x] 2.4 Mark each occurrence started/not-started by matching an existing `ClassSession` on `scheduleEntry.id` + `date`

## 3. Day's classes list view

- [x] 3.1 Create `Views/TodayClassesView.swift` with `@Query` for `TrainingClass` and `ClassSession`, building occurrences for today
- [x] 3.2 Add a segmented filter `Picker` (enum: To start / Started) and filter the list by `isStarted`
- [x] 3.3 Build a private row subview showing class name and start time, with a started/not-started + timing indicator
- [x] 3.4 Add `ContentUnavailableView` empty states (no classes for today; nothing in the selected filter)
- [x] 3.5 Add `#Preview` with an in-memory container registering all three models and sample data

## 4. Open + explicit start behavior

- [x] 4.1 Tapping an occurrence opens its detail via value-based `NavigationLink(value:)` + `navigationDestination(for: Occurrence.self)` (lazy; no work on render)
- [x] 4.2 Opening a not-yet-started occurrence creates NO session; the detail shows an explicit "Start Session" button
- [x] 4.3 "Start Session" creates + persists the `ClassSession` and transitions the detail to the started state in place
- [x] 4.4 An already-started occurrence opens its session directly (no Start button), and an occurrence never yields more than one session

## 5. Session detail view

- [x] 5.1 `Views/ClassSessionView.swift` shows a concise read-only summary: session name, day (`Weekday.displayName`), start time (`ScheduleEntry.startTimeDisplay`)
- [x] 5.2 Add a participants section with an empty-state placeholder (no participant data yet), shown only once started
- [x] 5.3 Add `#Preview` with an in-memory container and a sample occurrence
- [x] 5.4 `ClassSession` carries a stored `name`, defaulted on start to `YY/MM/dd <class name>` via `ClassSession.defaultName(date:className:)`

## 6. Navigation entry point

- [x] 6.1 Add a route/link from `ContentView`'s landing screen into `TodayClassesView`

## 7. Verification

- [x] 7.1 Build the app and confirm it compiles with the new model registered
- [x] 7.2 Manually verify on simulator: a class scheduled for today appears; opening it creates no session; "Start Session" creates one in place (no pop), it moves to the Started filter, and re-opening shows the same session
- [x] 7.3 Manually verify the session detail shows the correct definition summary and an empty participants placeholder
