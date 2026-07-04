## Context

`ClassSession` is a deliberately relationship-free snapshot (stores originating ids +
snapshotted definition, every property defaulted) so a session record survives edits/deletes of
its originating class or slot. `ClassSessionView` today renders an empty "Participants" section
(`ContentUnavailableView`) gated on the session being started; it has two entry paths via a
private `Source` enum — `.occurrence` (today, may be unstarted) and `.session` (history, always
started). Members, dogs, and the global (member, dog) `Combination` join now exist
(`club-membership`), and `Member.activeCombinations` already filters to combinations whose dog
is active.

This change records which combinations attended a session and shows them where the placeholder
was.

## Goals / Non-Goals

**Goals:**
- Record attendance as combinations present at a started session, via QR scan (device) or a
  list (simulator), with transparent selection when a member trains exactly one active dog.
- Store attendance immune to later edits/deletes of member/dog/combination, matching the
  `ClassSession` snapshot philosophy.
- Show and manage attendance from the session detail regardless of entry path.

**Non-Goals:**
- Attendance analytics, counts, or reporting.
- Explicitly marking a combination "absent" — attendance is the set of who was present.
- Per-class enrollment/rosters; editing a combination's member or dog (that is
  `club-membership`).
- A general QR-code system beyond looking up a member by club member id.

## Decisions

### `SessionAttendance` is a snapshot join, like `ClassSession`
A new `@Model SessionAttendance` with `id`, `sessionID` (the query key), `combinationID`
(de-dupe within a session), reference `memberID`/`dogID`, and snapshots `clubMemberID`,
`memberName`, `dogName`, `recordedAt` — all defaulted. Queried by `sessionID` with a
`#Predicate` UUID-equality filter (the same reliable filter `ClassSessionView` already uses for
its slot sessions). No relationships.
*Why:* an attendance record must survive later edits/deletes of the member/dog/combination, so
it snapshots identity rather than referencing it — identical reasoning to `ClassSession`.
*Alternatives considered:* a live `@Relationship` to `Combination` (rejected — a deleted or
re-paired combination would corrupt the historical record).

### QR payload is a URL carrying `member_id`; unknown ids register a new member
The scanned QR payload is a URL with the member's club member id in a `member_id` query-string
parameter. The app parses the URL (e.g. `URLComponents`), extracts `member_id`, and looks the
member up (trimmed, case-sensitive, per club-membership). A `member_id` that matches no member is
treated as a not-yet-entered club member: the app opens the club-membership member editor
pre-filled with that id so the user can register the remaining details, rather than rejecting the
scan. After the editor is dismissed, control returns to the session's add-participant flow so the
user can continue. A code that is not a URL carrying `member_id` is reported as unrecognized.
*Why:* the club issues QR codes as URLs, and an unrecognized id is normally a member who hasn't
been entered yet — onboarding them on the spot beats an error.
*Alternatives considered:* a bare-id payload (rejected — the real codes are URLs); rejecting
unknown ids outright (rejected — misses the register-on-scan opportunity).

### Transparent selection keys off active dogs
On identifying a member (by scan or list), the candidate combinations are
`member.activeCombinations` minus any already recorded present in this session. Exactly one
candidate → record it with no prompt; more than one → prompt for the dog; zero → explain (no
active dog, or all already recorded). A scanned `member_id` that matches no member instead opens
the register-a-new-member flow (above) rather than reporting nothing to record.
*Why:* the active flag exists precisely to drive this; it keeps the common single-dog case
frictionless.

### The QR scanner is gated on availability; the list is the universal path
`AddParticipantView` offers a "Scan" affordance only when `DataScannerViewController.isSupported
&& .isAvailable` (both false on the simulator), and always offers list selection. The scanner is
a small `UIViewControllerRepresentable` (`MemberScannerView`) wrapping
`DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])])`, forwarding the
payload string via a closure.
*Why:* lets the simulator exercise every flow via the list while the camera path is testable on
device; no code path is simulator-only-broken.

### Attendance is editable wherever the session detail is opened
A started session's attendance is shown and editable from `ClassSessionView` for both the today
(`.occurrence`, once started) and history (`.session`) paths — the same
`SessionAttendanceListView(sessionID:)`. This relaxes the previous "history detail is read-only"
behavior *for the participants section only*; the definition summary stays read-only and no
"Start Session" action is offered from history.
*Why:* it is the same underlying session; gating edits on entry path is arbitrary and would stop
a trainer correcting attendance they open from history. Confirmed with the user.

### `SessionAttendanceListView` owns a fixed-predicate query
Because `ClassSessionView`'s two sources fix identity only at init, extract the list into a child
initialized with `sessionID` that owns `@Query(filter: #Predicate { $0.sessionID == sessionID })`,
with add (sheet) and swipe-to-remove.

## Risks / Trade-offs

- **[Camera permission / entitlement]** the scanner needs `NSCameraUsageDescription` and runtime
  permission → add the key; degrade to list selection if denied/unavailable.
- **[Malformed QR]** a code that is not a URL carrying `member_id` → surface a clear
  "not recognized" message; never record silently.
- **[Unknown member id]** a valid `member_id` not in the database → open the member editor
  pre-filled to register the member rather than erroring; attendance waits until they have an
  active dog.
- **[Duplicate scans]** repeated recognition of the same code → de-dupe by `combinationID`
  within the session and ignore an already-recorded combination.
- **[Relaxing history read-only]** editing attendance from history changes established behavior →
  scoped to the participants section only; definition summary and no-Start-Session are preserved.

## Open Questions

None outstanding — QR payload and parsing, the register-on-scan return flow, and history
editability are all settled.
