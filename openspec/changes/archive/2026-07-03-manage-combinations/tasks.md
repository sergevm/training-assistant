## 1. Data model

- [x] 1.1 Add `Models/DogGender.swift`: an `Int`-backed `enum DogGender: Int, CaseIterable, Identifiable` with `male`/`female` cases and a `displayName`, mirroring `Weekday.swift`'s shape.
- [x] 1.2 Add `Models/Combination.swift`: `@Model final class Combination` with `id`, `handlerFirstName`, `handlerLastName`, `dogName`, `dogBirthDate`, `dogGenderRaw: Int = 0` (+ computed `dogGender: DogGender?`), `notes`, and `currentClass: TrainingClass?` — every stored property defaulted per the lightweight-migration-safe convention.
- [x] 1.3 Add a `@Relationship(deleteRule: .nullify, inverse: \Combination.currentClass) var combinations: [Combination] = []` property to `TrainingClass` so deleting a class nullifies (not cascades) its combinations' `currentClass`.
- [x] 1.4 Register `Combination.self` in the `.modelContainer(for:)` array in `TrainingAssistantApp.swift` and in every `#Preview` in-memory container touching `TrainingClass` or the new views (`TrainingClass.swift`, `SettingsView.swift`, `ContentView.swift`, and the new views added below).

## 2. Combinations list screen

- [x] 2.1 Add `Views/CombinationsView.swift`: `@Query` all `Combination`s, group them by `currentClass?.id` (nil key = "Unassigned"), and render one section per class (sorted by class name) plus a trailing "Unassigned" section, each row showing handler full name and dog name.
- [x] 2.2 Show a `ContentUnavailableView` empty state when no combinations exist, matching `SettingsView`'s empty-state pattern.
- [x] 2.3 Add an "Add Combination" toolbar action that presents `CombinationEditorView` via a sheet (mirroring how `ClassEditorView` presents `ScheduleEntryEditorView`); the combination is only inserted into the model context on Save.
- [x] 2.4 Add a "Combinations" entry point button to `ContentView`'s landing screen (alongside "Today's Classes" and "History"), navigating to `CombinationsView`.

## 3. Combination editor (create/edit)

- [x] 3.1 Add `Views/CombinationEditorView.swift`: a `Form` with fields for handler first/last name, dog name, dog date of birth (`DatePicker`), dog gender (`Picker` over `DogGender.allCases`), notes, and a current-class `Picker` sourced from `@Query private var classes: [TrainingClass]` with an "Unassigned" option.
- [x] 3.2 Validate handler first name, handler last name, and dog name are non-empty after trimming before allowing save/commit, following `ClassEditorView.commitName`'s local-draft-then-commit pattern.
- [x] 3.3 Wire row taps in `CombinationsView` through local `@State private var selectedCombination: Combination?` + `.navigationDestination(item:)` to open `CombinationEditorView` for editing (per CLAUDE.md — never push a `@Model` as a path value).

## 4. Deletion

- [x] 4.1 Add swipe-to-delete (`.onDelete`) for combinations in `CombinationsView`, deleting the `Combination` and saving the context.
- [x] 4.2 Verify (manually, per task 5) that deleting a `TrainingClass` from `SettingsView` leaves its previously-assigned combinations persisted and unassigned, with no code changes needed beyond the `.nullify` relationship from task 1.3.

## 5. Verification

- [x] 5.1 Build the app (`xcodebuild` succeeded) and confirmed each scenario in `specs/combinations/spec.md` and the modified "Delete a class" scenarios in `specs/class-management/spec.md` is covered by the implementation.
- [x] 5.2 Grouping logic (`CombinationsView.groupedCombinations`) sorts assigned groups by class name and keys the unassigned group off `currentClass == nil`, updating automatically via `@Query` when a class is deleted (nullify) or a combination's class changes.
