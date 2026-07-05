## MODIFIED Requirements

### Requirement: Filter the list by started state

The screen SHALL provide a control to filter the list between occurrences that have not yet been started and classes that have already been started (instantiated sessions). When the screen appears and no occurrence remains to start while at least one started session exists for the day, the screen SHALL auto-select the started filter. Auto-selection SHALL only ever switch from the not-yet-started filter to the started filter, and SHALL NOT override a filter the user selects while the screen is presented.

#### Scenario: Filter to not-yet-started

- **WHEN** the user selects the not-yet-started filter
- **THEN** the list shows only occurrences for which no `ClassSession` exists

#### Scenario: Filter to started

- **WHEN** the user selects the started filter
- **THEN** the list shows only occurrences for which a `ClassSession` exists

#### Scenario: Auto-select started when nothing is left to start

- **WHEN** the screen appears (including reappearing after a session detail is dismissed) and every occurrence for the day has a `ClassSession` and at least one exists
- **THEN** the started filter is selected automatically and the started list is shown

#### Scenario: Manual selection is not overridden

- **WHEN** the user manually selects the not-yet-started filter while nothing is left to start
- **THEN** the empty not-yet-started state remains shown until the user switches filters or the screen reappears
