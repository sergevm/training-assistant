# class-management Delta Specification

## MODIFIED Requirements

### Requirement: Settings entry point

The app SHALL provide a Settings area, reachable from the main screen. The
Settings area SHALL provide an entry to a dedicated Classes screen from which the
user can manage classes and their schedules.

#### Scenario: Open settings from main screen

- **WHEN** the user taps the Settings control on the main screen
- **THEN** the app navigates to the Settings screen showing an entry to the Classes screen

#### Scenario: Open the Classes screen from Settings

- **WHEN** the user selects the Classes entry on the Settings screen
- **THEN** the app navigates to the Classes screen showing the list of classes

### Requirement: List classes

The system SHALL display all persisted classes on the Classes screen, ordered by
name. The Classes screen SHALL be reachable from Settings and from the hamburger
menu on the primary screens.

#### Scenario: View existing classes

- **WHEN** the user opens the Classes screen and one or more classes exist
- **THEN** the system shows each class with its name

#### Scenario: No classes yet

- **WHEN** the user opens the Classes screen and no classes exist
- **THEN** the system shows an empty-state message inviting the user to add a class
