# class-sessions Specification

## Purpose
TBD - created by archiving change start-class. Update Purpose after archive.
## Requirements
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

### Requirement: Access session history

The app SHALL provide an entry point from the landing screen to a screen that lists past class sessions. This entry point SHALL be distinct from the existing day's-classes entry point.

#### Scenario: Open history from landing screen

- **WHEN** the user taps the history entry point on the landing screen
- **THEN** the app navigates to the session history screen showing all started sessions

#### Scenario: History is separate from today's classes

- **WHEN** the landing screen is shown
- **THEN** it offers both a day's-classes entry point and a distinct session-history entry point

### Requirement: List all started sessions newest first

The session history screen SHALL list every persisted `ClassSession`, ordered by session date descending (most recent first). Every started session SHALL appear regardless of how long ago it was started or whether its originating class or schedule slot still exists.

#### Scenario: Sessions listed most recent first

- **WHEN** sessions exist for several different dates
- **THEN** the history screen lists them ordered by date descending, with the most recent session's date first

#### Scenario: Today's sessions are included

- **WHEN** a session was started today
- **THEN** it appears in the session history list

#### Scenario: Session whose origin was deleted still appears

- **WHEN** a `ClassSession` exists but its originating `TrainingClass` or `ScheduleEntry` has since been deleted or edited
- **THEN** the session still appears in the history list, rendered from its stored snapshot

### Requirement: Group history by date

The session history screen SHALL group sessions by calendar day, presenting one section per day with a section header identifying that day. Day sections SHALL be ordered descending (most recent day first), and sessions within a day SHALL be ordered by start time. Each row SHALL identify the session (its name) and its start time.

#### Scenario: Sessions grouped under date headers

- **WHEN** the history list contains sessions from more than one calendar day
- **THEN** each day is shown as its own section with a date header, and the sections are ordered with the most recent day first

#### Scenario: Multiple sessions on the same day

- **WHEN** more than one session was started on the same calendar day
- **THEN** those sessions appear under that day's single section, ordered by start time

### Requirement: Empty history state

When no `ClassSession` has ever been started, the session history screen SHALL present an empty state rather than a blank list.

#### Scenario: No sessions have been started

- **WHEN** no `ClassSession` exists
- **THEN** the history screen shows an empty state explaining that no sessions have been held yet

### Requirement: Open a session from history

Tapping a session in the history list SHALL open that session's detail view. The definition
summary (name, day, start time) SHALL be read-only and rendered from the session's stored
snapshot so it displays correctly even if the originating class or slot no longer exists, and the
detail SHALL NOT offer a "Start Session" action. The detail SHALL show the session's recorded
attendance and allow managing it.

#### Scenario: Open a past session's detail

- **WHEN** the user taps a session in the history list
- **THEN** the app opens that session's detail view showing the session name, day of week, and
  start time from its snapshot

#### Scenario: History detail shows attendance and no start action

- **WHEN** the user views a session opened from history
- **THEN** the detail shows the session's recorded attendance and does not offer a "Start Session"
  action

#### Scenario: Detail renders when origin is gone

- **WHEN** the user opens the detail of a session whose originating class or slot was deleted or
  edited
- **THEN** the detail still displays the session's snapshotted name, day, and start time without
  error

