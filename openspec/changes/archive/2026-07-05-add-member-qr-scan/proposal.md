# Add Member via QR Scan

## Why

Members carry a club-issued QR code encoding their club member id, and the session-attendance
flow already scans it to record participants. Registering a new member in Settings → Club →
Members still requires typing the id by hand — error-prone for an externally issued token and
slower than pointing the camera at the card the trainer is already holding.

## What Changes

- The add-member sheet (Settings → Club → Members → Add) offers a "Scan Member QR" action on
  devices where the live scanner is available (not in the simulator).
- Scanning a valid member QR code pre-fills the club member id field; the user completes first
  and last name and confirms as today.
- Scanning a code that is not a valid member QR code informs the user and leaves the form
  unchanged.
- Scanning the id of an already-registered member informs the user that the member exists.
- The `member_id` URL payload parsing currently private to the attendance flow moves to a
  shared helper so both flows recognize the same QR format.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `club-membership`: the "Create a member" flow gains a scan-to-prefill entry path; new
  requirement covering scanning a member QR code when adding a member, including invalid and
  duplicate payload handling.

## Impact

- `TrainingAssistant/Views/MembersView.swift` — add scan button, scanner cover, and scan
  handling to the add-member sheet.
- `TrainingAssistant/Views/AddParticipantView.swift` — use the shared payload parser instead of
  its private static helper.
- `TrainingAssistant/Views/MemberScannerView.swift` (or a small new file) — home for the shared
  `member_id` payload parser.
- No model, schema, or dependency changes; `MemberScannerView` (VisionKit) is reused as-is.
