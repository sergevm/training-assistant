## Why

There is currently no way to record who is actually training in a class. `TrainingClass` and `ScheduleEntry` define the schedule, and `ClassSession` starts dated occurrences, but there is no roster of the handler-dog pairs ("combinations") attending. Trainers need a way to register combinations and see which class each one currently belongs to.

## What Changes

- Add a `Combination` entity: handler first name, handler last name, dog name, dog date of birth, dog gender, an optional current class assignment, and free-text notes.
- Add a new top-level "Combinations" entry point on the landing screen, alongside Today's Classes, History, and Settings.
- The Combinations screen lists all combinations, groupable/filterable by their current class (including an "Unassigned" group), and supports creating a combination.
- Tapping a combination opens a detail/edit view where the handler, dog, class assignment, and notes can be edited, and the combination can be deleted.
- A combination's current class is optional: it can be created and remain unassigned (e.g. a waiting-list entry) and assigned or reassigned to any existing `TrainingClass` at any time.
- Deleting a `TrainingClass` unassigns (does not delete) any combinations currently pointing to it, since a combination represents a real handler/dog and must survive the class it was in being removed.
- A combination may only be assigned to a `TrainingClass` that currently exists; the assignment picker offers exactly the persisted classes.

## Capabilities

### New Capabilities
- `combinations`: registering, listing, editing, assigning-to-class, and deleting handler-dog combinations.

### Modified Capabilities
- `class-management`: deleting a class must also clear the `currentClass` reference on any combinations assigned to it (cascade-to-null instead of cascade-delete), since combinations must outlive the class they were removed from.

## Impact

- New SwiftData model `Combination`, registered in `TrainingAssistantApp.swift`'s `.modelContainer(for:)` list and in relevant `#Preview` containers.
- New view(s): a Combinations list screen and a combination editor/detail screen, plus a new entry point on the landing screen.
- `TrainingClass` gains a `combinations` relationship (deleteRule `.nullify`) so deleting a class automatically clears `currentClass` on any combinations assigned to it, without manual cleanup code.
