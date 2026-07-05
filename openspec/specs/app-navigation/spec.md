# app-navigation Specification

## Purpose
TBD - created by archiving change add-hamburger-menu. Update Purpose after archive.
## Requirements
### Requirement: Hamburger menu on primary screens

The app SHALL show a hamburger menu control in the navigation bar of the primary
screens: the landing screen, the Today's Classes screen, and the Session History
screen. Tapping the control SHALL open a menu offering the navigation shortcuts
**Members** and **Classes**.

#### Scenario: Menu is available on the landing screen

- **WHEN** the user is on the landing screen
- **THEN** a hamburger menu control is visible in the navigation bar
- **AND** opening it shows the shortcuts Members and Classes

#### Scenario: Menu is available on Today's Classes and Session History

- **WHEN** the user is on the Today's Classes screen or the Session History screen
- **THEN** the same hamburger menu control is available with the same shortcuts

### Requirement: Menu shortcuts navigate in one tap

Selecting a shortcut from the hamburger menu SHALL push the corresponding screen
(Members or Classes) onto the current navigation stack in a single navigation
step, from whichever primary screen the menu was opened on.

#### Scenario: Navigate to Members from the menu

- **WHEN** the user opens the hamburger menu and selects Members
- **THEN** the Members screen is pushed onto the current navigation stack

#### Scenario: Navigate to Classes from the menu

- **WHEN** the user opens the hamburger menu and selects Classes
- **THEN** the Classes screen is pushed onto the current navigation stack

#### Scenario: Back returns to the originating screen

- **WHEN** the user reached Members or Classes via the hamburger menu and taps Back
- **THEN** the app returns to the screen the menu was opened from

### Requirement: Menu terminology

The hamburger menu SHALL label its shortcuts "Members" and "Classes". The term
"Class Definitions" MUST NOT appear in the user interface; dated, started
occurrences are called "Class Sessions".

#### Scenario: Shortcut labels

- **WHEN** the user opens the hamburger menu
- **THEN** the shortcuts read "Members" and "Classes"
