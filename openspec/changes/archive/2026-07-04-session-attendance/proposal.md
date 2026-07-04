## Why

A class session cannot yet record *who* trained. Now that members, dogs, and their
combinations are modeled, a trainer should be able to record which combinations attended a
session — by scanning a member's QR code on a device, or picking from a list in the simulator
— replacing the empty participants placeholder on the session detail.

## What Changes

- Add a `SessionAttendance` snapshot model: one record per (session, combination) that
  attended, storing the originating ids plus a snapshot of the member/dog identity so it
  survives later edits or deletes of the member, dog, or combination.
- Replace the participants placeholder in the session detail with a real attendance list that
  shows recorded attendees and offers an "add participant" action on a started session.
- **Add a participant by scanning a member QR code** (device): scan a URL QR whose `member_id`
  query parameter carries the club member id → find the member → if they train exactly one
  active dog, record that combination transparently; if several, prompt for the dog. A
  `member_id` not yet in the database opens a member editor pre-filled with that id to register
  the new member.
- **Add a participant from a list** (works in the simulator): pick a member from a searchable
  list, then pick the dog if the member trains more than one active dog, else record the only
  one.
- Prevent recording the same combination twice in a session; allow removing a participant.
- **BREAKING (spec):** the `class-sessions` "placeholder participants" requirement is removed
  and its "read-only history" behavior is modified so a session's recorded attendance is shown
  (and manageable) wherever the session detail is opened.

## Capabilities

### New Capabilities
- `session-attendance`: recording which combinations attended a class session — QR-scan and
  list entry, transparent single-active-dog selection, self-contained snapshot storage,
  duplicate prevention, and participant removal.

### Modified Capabilities
- `class-sessions`: the session detail's participants section shows recorded attendance instead
  of an empty placeholder, and a session opened from history shows that same attendance rather
  than a read-only placeholder.

## Impact

- **New model**: `SessionAttendance` under `Models/` — a relationship-free snapshot (every
  property defaulted, migration-safe), registered in the `Schema` in `TrainingAssistantApp`
  and in every relevant `#Preview` container.
- **New views**: `SessionAttendanceListView` (fixed-`sessionID` `@Query`), `AddParticipantView`
  (scan/list entry + dog selection), `MemberScannerView` (a VisionKit `DataScannerViewController`
  `UIViewControllerRepresentable`).
- **Modify** `ClassSessionView` to host the attendance list in place of the placeholder.
- **Info.plist**: add `NSCameraUsageDescription`; the QR scanner is gated on
  `DataScannerViewController` availability, so the simulator falls back to list selection.
- No third-party dependencies — VisionKit is a system framework; the camera is used only on
  device.
- Depends on the `club-membership` capability (Member, Dog, Combination) shipped in the prior
  change.
