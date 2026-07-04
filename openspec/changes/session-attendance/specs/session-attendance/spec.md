## ADDED Requirements

### Requirement: Record attendance on a started session

The session detail SHALL show the combinations recorded as present at the session and SHALL
offer an action to add a participant. Attendance SHALL be available only once the session has
been started. When no attendance is recorded, the section SHALL present an empty state.

#### Scenario: Empty attendance on a started session

- **WHEN** the user views a started session that has no recorded attendance
- **THEN** the participants section shows an empty state and an add-participant action

#### Scenario: Recorded attendance is listed

- **WHEN** attendance has been recorded for a session
- **THEN** the participants section lists each recorded combination by member name and dog name

#### Scenario: Attendance unavailable before starting

- **WHEN** the user views an occurrence that has not been started
- **THEN** no attendance list or add-participant action is shown

### Requirement: Attendance is stored as a self-contained snapshot

Each attendance record SHALL store the originating session id and combination id together with a
snapshot of the member and dog identity (club member id, member name, dog name), so it renders
correctly even after the member, dog, or combination is later edited or deleted.

#### Scenario: Attendance survives deletion of its combination

- **WHEN** a combination recorded in a session — or its member or dog — is later edited or deleted
- **THEN** the session's attendance still lists that participant from its stored snapshot

### Requirement: Add a participant by scanning a member QR code

On a device with a camera, the system SHALL let the user add a participant by scanning a
member's QR code. The QR payload is a URL that carries the member's club member id in a
`member_id` query-string parameter. The system SHALL extract that id from the URL, look the
member up by it, and record a combination chosen from the member's active dogs.

#### Scenario: Scan a known member who trains one active dog

- **WHEN** the user scans the QR code of a known member who trains exactly one active dog
- **THEN** the system records that member-and-dog combination as present without further prompting

#### Scenario: Scan a known member who trains several active dogs

- **WHEN** the user scans the QR code of a known member who trains more than one active dog
- **THEN** the system prompts the user to choose which of that member's active dogs to record

#### Scenario: Scan a code without a usable member id

- **WHEN** the scanned code is not a URL carrying a `member_id` query-string parameter
- **THEN** the system records nothing and informs the user that the code was not recognized

### Requirement: Register a new member scanned from a QR code

When a scanned `member_id` matches no existing member, the system SHALL open a member
registration view pre-filled with that club member id so the user can register the member's
remaining details. The system SHALL NOT record attendance for a member that does not yet exist.
After the registration view is dismissed, the system SHALL return to the session's participant
registration.

#### Scenario: Scan a member id that is not yet in the database

- **WHEN** the user scans a QR code whose `member_id` matches no existing member
- **THEN** the system opens a member editor with the club member id pre-filled for the user to
  complete and save, and records no attendance until that member exists and has an active dog

#### Scenario: Return to participant registration after registering

- **WHEN** the user finishes with the member registration view opened from a scan
- **THEN** the system returns to the session's participant registration flow

### Requirement: Add a participant from a member list

The system SHALL let the user add a participant by selecting a member from a searchable list (by
first name, last name, or club member id) and then recording a dog from that member's active
dogs. This path SHALL be available without a camera.

#### Scenario: Pick a member with one active dog

- **WHEN** the user selects, from the list, a member who trains exactly one active dog
- **THEN** the system records that combination as present without prompting for a dog

#### Scenario: Pick a member with several active dogs

- **WHEN** the user selects a member who trains more than one active dog
- **THEN** the system prompts the user to choose which active dog to record

### Requirement: A member with no active dog cannot be recorded

The system SHALL record nothing, and SHALL explain why, when an identified member has no active
dog.

#### Scenario: Member has no active dog

- **WHEN** the user identifies a member who trains no active dog
- **THEN** the system records nothing and informs the user there is no active dog to record

### Requirement: A member can attend a session only once

The system SHALL record each member as present at most once per session; a member already
recorded SHALL NOT be added again, even with a different dog. Members already recorded are not
offered in the add-participant list.

#### Scenario: Re-adding an already-present member

- **WHEN** the user tries to record a member already present in the session, with any dog
- **THEN** the system does not add a second record and indicates the member is already recorded

### Requirement: Remove a participant from a session

The system SHALL allow removing a recorded participant from a session's attendance.

#### Scenario: Remove a participant

- **WHEN** the user removes a participant from a session's attendance
- **THEN** the system deletes that attendance record and the participant no longer appears

### Requirement: Offer scanning only when available, with list fallback

The system SHALL offer the QR-scan action only when barcode scanning is available on the device,
and SHALL always offer list selection. On a device without scanning support (for example the
simulator), only list selection is offered.

#### Scenario: Scanning unavailable

- **WHEN** the device does not support barcode scanning
- **THEN** the add-participant flow offers list selection and does not offer the scan action
