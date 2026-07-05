## ADDED Requirements

### Requirement: Scan a member QR code to pre-fill the club member id

The add-member flow SHALL offer scanning a member QR code on devices where the live scanner is
available, and SHALL hide the scan action where it is not. A member QR code encodes the club
member id as the `member_id` query-string parameter of a URL payload — the same format the
session-attendance flow recognizes. Scanning a valid code SHALL pre-fill the club member id
field with the scanned id (trimmed) without creating the member; creation still requires the
user to confirm the form.

#### Scenario: Scan a valid member QR code

- **WHEN** the user, adding a member, scans a QR code whose URL payload carries a non-empty
  `member_id` that matches no existing member
- **THEN** the scanner is dismissed and the club member id field is pre-filled with the scanned
  id
- **AND** no member is created until the user confirms the form

#### Scenario: Scan a code that is not a member QR code

- **WHEN** the user, adding a member, scans a QR code whose payload is not a URL carrying a
  non-empty `member_id` parameter
- **THEN** the system informs the user the code is not a valid member QR code
- **AND** the form is left unchanged

#### Scenario: Scan the id of an already-registered member

- **WHEN** the user, adding a member, scans a QR code whose `member_id` matches an existing
  member's club member id after trimming, compared case-sensitively
- **THEN** the system informs the user that a member with that id already exists
- **AND** the form is left unchanged

#### Scenario: Scanner not available

- **WHEN** the user opens the add-member flow on a device without live-scanner support (for
  example the simulator)
- **THEN** no scan action is offered
- **AND** the manual entry path works unchanged
