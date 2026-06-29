## 1. Data model & persistence

- [x] 1.1 Add a `Weekday` enum (1–7, Calendar weekday convention) with display labels and an ordered `allCases` for pickers
- [x] 1.2 Create `TrainingClass` `@Model` (id: UUID, name: String, schedule: [ScheduleEntry] with cascade delete)
- [x] 1.3 Create `ScheduleEntry` `@Model` (id: UUID, dayOfWeek: Int, startHour: Int, back-reference to TrainingClass)
- [x] 1.4 Configure the SwiftData `ModelContainer` on the app's `WindowGroup` via `.modelContainer(for:)`

## 2. App shell & navigation

- [x] 2.1 Replace the placeholder `ContentView` with a `NavigationStack` and an entry point (toolbar button or link) into Settings
- [x] 2.2 Create `SettingsView` as the destination, injected with the model context

## 3. Class management

- [x] 3.1 In `SettingsView`, `@Query` and list classes ordered by name, with an empty-state message when none exist
- [x] 3.2 Add "create class" flow with non-empty (trimmed) name validation; disable confirm on blank input
- [x] 3.3 Add swipe-to-delete on a class that cascade-deletes its schedule entries
- [x] 3.4 Navigate from a class row into `ClassEditorView`

## 4. Class editor & scheduling

- [x] 4.1 Build `ClassEditorView`: edit/rename the class name (reusing the non-empty validation)
- [x] 4.2 List the class's schedule entries ordered by day-of-week then start hour, showing day + locale-formatted start time
- [x] 4.3 Build `ScheduleEntryEditorView` with a day-of-week picker and a start-time picker stepping in quarter-hour increments (0/15/30/45) across the day
- [x] 4.4 Implement add-entry: insert a new `ScheduleEntry` (day, hour, minute) for the class
- [x] 4.5 Enforce uniqueness of (dayOfWeek, startHour, startMinute) within the class on insert; surface a "already exists" message and block the duplicate
- [x] 4.6 Implement remove of a single schedule entry without deleting the class

## 5. Verification

- [ ] 5.1 Build and run on the iOS 26 iPhone simulator; create a class, add multiple entries (incl. same day twice and across days), edit, and delete
- [ ] 5.2 Verify persistence by relaunching the app and confirming classes and schedules remain
- [ ] 5.3 Verify duplicate prevention and blank-name validation behave per the specs
