## ADDED Requirements

### Requirement: Access the day's classes

The app SHALL provide an entry point from the landing screen to a screen that lists the classes relevant to the current day.

#### Scenario: Open from landing screen

- **WHEN** the user taps the classes entry point on the landing screen
- **THEN** the app navigates to the day's classes screen showing the candidate occurrences and started sessions for the current day

### Requirement: List candidate class occurrences for the day

The screen SHALL derive candidate occurrences for the current day by matching each `TrainingClass`'s `ScheduleEntry` slots against the current weekday, and SHALL list them ordered by start time. Each row SHALL show the class name and the slot's start time.

#### Scenario: Class has a slot scheduled for today

- **WHEN** a `TrainingClass` has a `ScheduleEntry` whose `dayOfWeek` matches today's weekday
- **THEN** an occurrence for that class and slot appears in the day's list with its start time

#### Scenario: Class has no slot scheduled for today

- **WHEN** a `TrainingClass` has no `ScheduleEntry` matching today's weekday
- **THEN** no occurrence for that class appears in the day's list

#### Scenario: Multiple slots on the same day

- **WHEN** a `TrainingClass` has more than one `ScheduleEntry` for today's weekday
- **THEN** each slot appears as its own distinct occurrence in the list

#### Scenario: No classes are scheduled for today

- **WHEN** no `TrainingClass` has a `ScheduleEntry` matching today's weekday and no session exists for today
- **THEN** the screen shows an empty state explaining there are no classes for the day

### Requirement: Distinguish not-yet-started from started occurrences

Each listed item SHALL reflect whether a `ClassSession` already exists for its occurrence (started) or not (not yet started).

#### Scenario: Occurrence not yet started

- **WHEN** no `ClassSession` exists for an occurrence's class, slot, and date
- **THEN** the occurrence is presented as not yet started

#### Scenario: Occurrence already started

- **WHEN** a `ClassSession` exists for an occurrence's class, slot, and date
- **THEN** the occurrence is presented as started

### Requirement: Filter the list by started state

The screen SHALL provide a control to filter the list between occurrences that have not yet been started and classes that have already been started (instantiated sessions).

#### Scenario: Filter to not-yet-started

- **WHEN** the user selects the not-yet-started filter
- **THEN** the list shows only occurrences for which no `ClassSession` exists

#### Scenario: Filter to started

- **WHEN** the user selects the started filter
- **THEN** the list shows only occurrences for which a `ClassSession` exists

### Requirement: Open an occurrence and start a session explicitly

Tapping an occurrence SHALL open a detail view for it. Opening an occurrence SHALL NOT create a `ClassSession`. When the occurrence has no session yet, the detail view SHALL present an explicit "Start Session" action; only invoking that action creates and persists the `ClassSession`. When the occurrence already has a session, the detail view SHALL show that session directly. A given occurrence SHALL never produce more than one `ClassSession`.

#### Scenario: Opening a not-yet-started occurrence does not create a session

- **WHEN** the user taps an occurrence that has no `ClassSession`
- **THEN** the app opens its detail view showing the class definition and a "Start Session" action, and no `ClassSession` is created

#### Scenario: Explicitly starting a session

- **WHEN** the user invokes "Start Session" on a not-yet-started occurrence
- **THEN** the app creates a `ClassSession` for the class, slot, and date, persists it, and the detail view shows the started session

#### Scenario: Opening an already-started occurrence

- **WHEN** the user taps an occurrence that already has a `ClassSession`
- **THEN** the app opens that session's detail directly, with no "Start Session" action and without creating a new session

#### Scenario: Starting is not duplicated

- **WHEN** an occurrence already has a `ClassSession`
- **THEN** the app never creates a second `ClassSession` for the same class, slot, and date

### Requirement: Session has a default name

When a `ClassSession` is started it SHALL be given a default name composed of the session date formatted as `YY/MM/dd` followed by the class definition's name (e.g. `26/06/30 Puppy Class`). The name is stored on the session so it can be changed independently in a later change.

#### Scenario: Default name on start

- **WHEN** the user starts a session for a class named "Puppy Class" on 30 June 2026
- **THEN** the session's name defaults to "26/06/30 Puppy Class"

### Requirement: View session detail with concise definition

The session detail view SHALL display a concise, read-only summary including the session name, the scheduled day, and the start time. For a not-yet-started occurrence the same summary SHALL use the default name it would receive on start.

#### Scenario: Show definition summary

- **WHEN** the user opens a session detail view
- **THEN** the view displays the session name, the day of week, and the start time of the session's slot

### Requirement: Show placeholder participants list

The session detail view SHALL include a participants section that is empty for now, presenting an empty state rather than any participant data.

#### Scenario: Participants section is empty

- **WHEN** the user views a session detail
- **THEN** the participants section shows an empty state indicating no participants are recorded yet
