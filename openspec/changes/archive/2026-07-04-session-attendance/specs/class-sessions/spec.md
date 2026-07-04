## REMOVED Requirements

### Requirement: Show placeholder participants list

**Reason**: Replaced by real recorded attendance. The `session-attendance` capability makes the
session detail's participants section list the combinations recorded as present and offer an
add-participant action, instead of an always-empty placeholder.

**Migration**: No data migration is required. The participants section that previously showed an
empty placeholder now shows recorded attendance; a started session with no attendance recorded
shows an empty state.

## MODIFIED Requirements

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
