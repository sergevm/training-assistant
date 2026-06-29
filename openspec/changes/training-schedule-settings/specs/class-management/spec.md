## ADDED Requirements

### Requirement: Settings entry point

The app SHALL provide a Settings area, reachable from the main screen, from which the user can manage classes and their schedules.

#### Scenario: Open settings from main screen

- **WHEN** the user taps the Settings control on the main screen
- **THEN** the app navigates to the Settings screen showing the list of classes

### Requirement: Create a class

The system SHALL allow the user to create a class identified by a name. The name MUST be non-empty after trimming surrounding whitespace.

#### Scenario: Create a class with a valid name

- **WHEN** the user enters a non-empty name and confirms creation
- **THEN** the system persists a new class with that name and shows it in the class list

#### Scenario: Reject a blank name

- **WHEN** the user attempts to create a class with an empty or whitespace-only name
- **THEN** the system does not create the class and the confirm action remains disabled or surfaces a validation message

### Requirement: List classes

The system SHALL display all persisted classes in the Settings area, ordered by name.

#### Scenario: View existing classes

- **WHEN** the user opens the Settings screen and one or more classes exist
- **THEN** the system shows each class with its name

#### Scenario: No classes yet

- **WHEN** the user opens the Settings screen and no classes exist
- **THEN** the system shows an empty-state message inviting the user to add a class

### Requirement: Edit a class name

The system SHALL allow the user to rename an existing class, subject to the same non-empty validation as creation.

#### Scenario: Rename a class

- **WHEN** the user changes a class name to a non-empty value and confirms
- **THEN** the system persists the new name and reflects it in the class list

### Requirement: Delete a class

The system SHALL allow the user to delete a class. Deleting a class MUST also remove all of its schedule entries.

#### Scenario: Delete a class

- **WHEN** the user deletes a class
- **THEN** the system removes the class and all of its schedule entries from the local database, and the class no longer appears in the list
