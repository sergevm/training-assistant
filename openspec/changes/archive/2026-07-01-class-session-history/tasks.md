## 1. Session detail from a snapshot

- [x] 1.1 Add a session-based path to `Views/ClassSessionView.swift` (e.g. `init(session: ClassSession)`) that renders the summary — name, day (`Weekday(rawValue: dayOfWeek)?.displayName`), start time (from `startHour`/`startMinute`) — from the session's stored snapshot
- [x] 1.2 In the session-based path, always show the started state: participants placeholder, no "Start Session" button
- [x] 1.3 Keep the existing occurrence-based initializer working for the today flow; extract a shared summary subview if it reduces branching
- [x] 1.4 Update/extend `#Preview` to cover the session-based path (in-memory container with a sample `ClassSession`)

## 2. Session history view

- [x] 2.1 Create `Views/SessionHistoryView.swift` with `@Query(sort: \ClassSession.date, order: .reverse)` over all sessions
- [x] 2.2 Group sessions into date buckets keyed by `Calendar.current.startOfDay(for:)`; emit one `List` `Section` per day, day headers ordered descending
- [x] 2.3 Order sessions within a day by `startHour`/`startMinute`
- [x] 2.4 Build a row subview showing the session `name` and its start time
- [x] 2.5 Add a `ContentUnavailableView` empty state for when no sessions exist
- [x] 2.6 Add `#Preview` with an in-memory container registering all three models and sample sessions across multiple days

## 3. Navigation

- [x] 3.1 Open a session's detail from a history row via `@State` selection + `.navigationDestination(item:)` (mirrors `TodayClassesView`; a value-based `ClassSession` path loops because the model is a reference type)
- [x] 3.2 Add a history entry point on `ContentView`'s landing screen, distinct from the existing "Today's Classes" button

## 4. Verification

- [x] 4.1 Build the app and confirm it compiles
- [x] 4.2 Manually verify on simulator: start sessions on (simulated) different days, open History from the landing screen, and confirm they are grouped by date with the most recent day first
- [x] 4.3 Verify tapping a history row opens the session detail with the correct name, day, and start time, showing the participants placeholder and no "Start Session" action
- [x] 4.4 Verify the empty state shows when no sessions exist
- [x] 4.5 Verify a session whose originating class/slot was deleted still lists and opens correctly
