# combinations Specification

## Purpose
TBD - created by archiving change manage-combinations. Update Purpose after archive.
## Requirements
### Requirement: Combinations entry point

The app SHALL provide a top-level entry point, reachable from the landing screen, to a Combinations screen. This entry point SHALL be distinct from the existing Today's Classes, History, and Settings entry points.

#### Scenario: Open Combinations from landing screen

- **WHEN** the user taps the Combinations entry point on the landing screen
- **THEN** the app navigates to the Combinations screen showing the list of registered combinations

### Requirement: Register a combination

The system SHALL allow the user to create a combination identified by a handler first name, handler last name, dog name, dog date of birth, and dog gender, with an optional free-text notes field. Handler first name, handler last name, and dog name MUST each be non-empty after trimming surrounding whitespace.

#### Scenario: Create a combination with valid required fields

- **WHEN** the user enters a non-empty handler first name, last name, and dog name, selects a dog date of birth and gender, and confirms creation
- **THEN** the system persists a new combination with those values and shows it in the combinations list

#### Scenario: Reject a blank required field

- **WHEN** the user attempts to create a combination with an empty or whitespace-only handler first name, handler last name, or dog name
- **THEN** the system does not create the combination and the confirm action remains disabled or surfaces a validation message

### Requirement: Class assignment is optional and changeable

A combination's current class assignment SHALL be optional. The system SHALL allow creating a combination without a current class, and SHALL allow assigning, reassigning, or clearing a combination's current class to any persisted `TrainingClass` at any time after creation.

#### Scenario: Create a combination without a class

- **WHEN** the user creates a combination without selecting a current class
- **THEN** the system persists the combination as unassigned

#### Scenario: Assign a class after creation

- **WHEN** the user selects a current class for a previously unassigned combination
- **THEN** the system persists that class as the combination's current class

#### Scenario: Reassign to a different class

- **WHEN** the user changes an already-assigned combination's current class to a different persisted class
- **THEN** the system persists the new class as the combination's current class

#### Scenario: Clear an assignment back to unassigned

- **WHEN** the user clears a combination's current class selection
- **THEN** the system persists the combination as unassigned

### Requirement: List combinations grouped by current class

The Combinations screen SHALL list all persisted combinations, grouped into one section per current class plus a distinct "Unassigned" section for combinations with no current class. Each row SHALL show the handler's full name and the dog's name.

#### Scenario: Combinations grouped under their class

- **WHEN** two or more combinations share the same current class
- **THEN** they appear together under that class's section on the Combinations screen

#### Scenario: Unassigned combinations shown separately

- **WHEN** one or more combinations have no current class
- **THEN** they appear together under a distinct "Unassigned" section

#### Scenario: Empty state when no combinations exist

- **WHEN** the user opens the Combinations screen and no combination has been registered
- **THEN** the system shows an empty-state message inviting the user to register a combination

### Requirement: Edit a combination

The system SHALL allow the user to edit an existing combination's handler first name, handler last name, dog name, dog date of birth, dog gender, notes, and current class, subject to the same required-field validation as creation.

#### Scenario: Edit and persist changes

- **WHEN** the user changes one or more fields of an existing combination to valid values and confirms
- **THEN** the system persists the updated values and reflects them in the combinations list

### Requirement: Delete a combination

The system SHALL allow the user to delete a combination. Deleting a combination SHALL NOT affect its current (or former) class or any other combination.

#### Scenario: Delete a combination

- **WHEN** the user deletes a combination
- **THEN** the system removes the combination from the local database and it no longer appears in the combinations list, and its current class and other combinations are unaffected

### Requirement: Combination survives deletion of its current class

When a `TrainingClass` that one or more combinations are currently assigned to is deleted, those combinations SHALL remain persisted with their current class cleared to unassigned.

#### Scenario: Class deleted while combinations are assigned to it

- **WHEN** a class with one or more combinations currently assigned to it is deleted
- **THEN** the system keeps those combinations persisted, moves them to the "Unassigned" section, and does not delete them
