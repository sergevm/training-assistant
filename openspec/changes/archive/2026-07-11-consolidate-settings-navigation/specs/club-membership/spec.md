## MODIFIED Requirements

### Requirement: Club management entry point

The app SHALL provide access to member management from the hamburger menu on the
primary screens, from which the user can manage members. Dogs are managed in the
context of the member who trains them, not as a standalone list.

#### Scenario: Open Members from the hamburger menu

- **WHEN** the user opens the hamburger menu on a primary screen
- **THEN** a Members entry is shown that navigates to the Members screen
- **AND** the existing Classes management remains available from the same menu
