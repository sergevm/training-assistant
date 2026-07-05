# Design: Add Member via QR Scan

## Context

Two existing pieces make this change small:

- `MemberScannerView` wraps VisionKit's `DataScannerViewController` for live QR scanning and
  forwards the first payload string. It only works where the scanner is supported and available
  (a real device, never the simulator).
- `AddParticipantView` already scans member QR codes for session attendance. It parses the
  payload with a private static helper, `memberID(fromURL:)`, which reads the `member_id`
  query-string parameter from a URL payload, and gates the scan button behind
  `DataScannerViewController.isSupported && .isAvailable`.

The add-member sheet (`AddMemberView`, private to `MembersView.swift`) is a plain form: club
member id, first name, last name, with trimming, non-empty and uniqueness validation on the id.

## Goals / Non-Goals

**Goals:**

- Scan a member QR code from the add-member sheet to pre-fill the club member id.
- Recognize exactly the same payload format as the attendance flow (single parser, one source
  of truth).
- Keep the manual typing path unchanged; scanning is an accelerator, not a replacement.

**Non-Goals:**

- Auto-creating the member on scan. The attendance flow does that because its goal is recording
  presence; here the user is deliberately filling a form and still needs to enter names.
- Generating or displaying QR codes for members.
- Changing the `Member` model or the QR payload format.

## Decisions

### 1. Pre-fill the form rather than insert-on-scan

A successful scan sets the `clubMemberID` field and returns to the form. The existing
Add-button validation (non-empty, unique) stays the single enforcement point.
*Alternative considered*: insert a member immediately and push the editor (what
`AddParticipantView` does for unknown ids). Rejected: in the Members admin flow the user is
composing a new record; silently persisting a half-empty member on scan would surprise, and
cancel would have to delete it.

### 2. Duplicate ids are rejected at scan time, not just at Add time

When the scanned id matches an existing member (trimmed, case-sensitive — same comparison as
the Add button), show the existing "Member Already Exists" alert immediately and leave the form
unchanged. Waiting until Add would let the user type both names before learning the scan was
pointless.

### 3. Extract the payload parser to a shared `MemberQRCode` helper

Move `AddParticipantView.memberID(fromURL:)` into a small `MemberQRCode` enum (namespace) in
`MemberScannerView.swift`, next to the scanner it interprets. `AddParticipantView` and
`AddMemberView` both call it. *Alternative considered*: have `MembersView` call the static on
`AddParticipantView`. Rejected: a Settings-area view depending on a session-flow view is a
wrong-direction dependency.

### 4. Same presentation pattern as the attendance scanner

Scan button in its own form/list section gated on `DataScannerViewController.isSupported &&
.isAvailable`, scanner presented in a `fullScreenCover` wrapped in a `NavigationStack` with a
Cancel toolbar button. Matching `AddParticipantView` keeps the two scan experiences identical.

## Risks / Trade-offs

- [Scanner unavailable in the simulator] → The button is hidden there; the manual path remains,
  so the flow stays fully testable in previews/simulator.
- [User scans, then edits the id into a duplicate] → Unchanged from today: the Add-button
  validation still catches it. Scan-time checking is an early warning, not the enforcement.
- [Payload format drift between flows] → Eliminated by the shared `MemberQRCode` parser.
