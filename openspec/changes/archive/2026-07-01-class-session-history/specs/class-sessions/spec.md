## ADDED Requirements

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

Tapping a session in the history list SHALL open that session's read-only detail view. The detail SHALL be rendered from the session's stored snapshot (name, day, start time) so it displays correctly even if the originating class or slot no longer exists, and SHALL show the started-session presentation — the participants placeholder and no "Start Session" action.

#### Scenario: Open a past session's detail

- **WHEN** the user taps a session in the history list
- **THEN** the app opens that session's detail view showing the session name, day of week, and start time from its snapshot

#### Scenario: History detail is read-only started state

- **WHEN** the user views a session opened from history
- **THEN** the detail shows the participants placeholder and does not offer a "Start Session" action

#### Scenario: Detail renders when origin is gone

- **WHEN** the user opens the detail of a session whose originating class or slot was deleted or edited
- **THEN** the detail still displays the session's snapshotted name, day, and start time without error
