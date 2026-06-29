## ADDED Requirements

### Requirement: Define a weekly schedule entry

The system SHALL allow the user to add a schedule entry to a class. A schedule entry MUST consist of a day of the week and a start time. The start time MUST fall on a quarter-hour boundary (0, 15, 30, or 45 minutes past the hour); other minute values MUST NOT be selectable. The class duration is fixed at one hour and is not user-editable.

#### Scenario: Add a schedule entry

- **WHEN** the user picks a day of the week and a start time for a class and confirms
- **THEN** the system persists a schedule entry for that class with the chosen day and start time, implying a one-hour duration

#### Scenario: Start time is restricted to quarter hours

- **WHEN** the user chooses the start time for a schedule entry
- **THEN** the only selectable minute values are 0, 15, 30, and 45

### Requirement: Multiple weekly occurrences

The system SHALL allow a class to have more than one schedule entry, including multiple entries on the same day of the week at different start times.

#### Scenario: Schedule a class on multiple days

- **WHEN** the user adds schedule entries for a class on two or more different days of the week
- **THEN** the system persists all entries and displays them for that class

#### Scenario: Schedule a class twice on the same day

- **WHEN** the user adds two schedule entries for the same class on the same day with different start times
- **THEN** the system persists both entries

### Requirement: Prevent duplicate schedule entries

The system SHALL prevent adding a schedule entry that has the same day of the week and start time as an existing entry on the same class.

#### Scenario: Reject a duplicate entry

- **WHEN** the user attempts to add a schedule entry whose day and start time already exist on that class
- **THEN** the system does not create a duplicate and surfaces a message indicating the entry already exists

### Requirement: View a class schedule

The system SHALL display all schedule entries belonging to a class, ordered by day of the week and then start time.

#### Scenario: View schedule for a class

- **WHEN** the user opens a class that has one or more schedule entries
- **THEN** the system lists each entry showing its day of the week and start time

### Requirement: Remove a schedule entry

The system SHALL allow the user to remove an individual schedule entry from a class without deleting the class.

#### Scenario: Delete a single schedule entry

- **WHEN** the user deletes a schedule entry from a class
- **THEN** the system removes only that entry from the local database and the class and its remaining entries are unchanged
