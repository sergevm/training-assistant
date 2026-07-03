## MODIFIED Requirements

### Requirement: Delete a class

The system SHALL allow the user to delete a class. Deleting a class MUST also remove all of its schedule entries. Deleting a class MUST NOT delete any combinations currently assigned to it; instead, those combinations' current class assignment MUST be cleared so they remain persisted as unassigned.

#### Scenario: Delete a class

- **WHEN** the user deletes a class
- **THEN** the system removes the class and all of its schedule entries from the local database, and the class no longer appears in the list

#### Scenario: Combinations assigned to a deleted class become unassigned

- **WHEN** the user deletes a class that one or more combinations are currently assigned to
- **THEN** the system removes the class but keeps those combinations persisted with their current class cleared to unassigned
