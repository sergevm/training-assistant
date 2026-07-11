## MODIFIED Requirements

### Requirement: Hamburger menu on primary screens

The app SHALL show a hamburger menu control at the trailing (top-right) position
of the navigation bar on the primary screens: the landing screen, the Today's
Classes screen, and the Session History screen. Tapping the control SHALL open a
menu offering the navigation shortcuts **Members** and **Classes**, followed by
a visually separated **Sign Out** action. The hamburger menu SHALL be the only
navigation-hub control in the navigation bar; the app MUST NOT show a separate
Settings control.

#### Scenario: Menu is available on the landing screen

- **WHEN** the user is on the landing screen
- **THEN** a hamburger menu control is visible at the trailing position of the navigation bar
- **AND** opening it shows the shortcuts Members and Classes and a separated Sign Out action
- **AND** no gear/Settings control is present

#### Scenario: Menu is available on Today's Classes and Session History

- **WHEN** the user is on the Today's Classes screen or the Session History screen
- **THEN** the same hamburger menu control is available at the same trailing position with the same entries

## ADDED Requirements

### Requirement: Sign out from the hamburger menu

The hamburger menu SHALL offer a destructive **Sign Out** action. Selecting it
SHALL present a confirmation dialog stating that classes and schedule data stay
on the device; only upon confirmation SHALL the app end the session. Cancelling
SHALL leave the session untouched.

#### Scenario: Confirm sign-out

- **WHEN** the user selects Sign Out from the hamburger menu and confirms the dialog
- **THEN** the session is ended and the login screen is shown

#### Scenario: Cancel sign-out

- **WHEN** the user selects Sign Out from the hamburger menu and cancels the dialog
- **THEN** the user remains signed in on the same screen
