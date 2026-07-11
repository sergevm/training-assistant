## REMOVED Requirements

### Requirement: Settings entry point

**Reason**: The Settings screen is removed; it only duplicated the hamburger
menu's Members and Classes shortcuts. The hamburger menu on the primary screens
is now the single entry point.
**Migration**: Open Classes via the hamburger menu at the top right of the
landing, Today's Classes, or Session History screen.

## MODIFIED Requirements

### Requirement: List classes

The system SHALL display all persisted classes on the Classes screen, ordered by
name. The Classes screen SHALL be reachable from the hamburger menu on the
primary screens.

#### Scenario: View existing classes

- **WHEN** the user opens the Classes screen and one or more classes exist
- **THEN** the system shows each class with its name

#### Scenario: No classes yet

- **WHEN** the user opens the Classes screen and no classes exist
- **THEN** the system shows an empty-state message inviting the user to add a class
