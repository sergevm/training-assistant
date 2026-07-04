## 1. Model

- [x] 1.1 Create `Models/SessionAttendance.swift` — `@Model` with `id: UUID = UUID()`, `sessionID: UUID = UUID()`, `combinationID: UUID = UUID()`, `memberID: UUID = UUID()`, `dogID: UUID = UUID()`, and snapshots `clubMemberID: String = ""`, `memberName: String = ""`, `dogName: String = ""`, `recordedAt: Date = Date(timeIntervalSince1970: 0)` (all defaulted; no relationships)
- [x] 1.2 Add a convenience initializer that snapshots from a `Combination` + `sessionID` (member name, dog name, ids)

## 2. Schema & preview registration

- [x] 2.1 Add `SessionAttendance.self` to the `Schema([...])` in `TrainingAssistantApp.swift`
- [x] 2.2 Add `SessionAttendance.self` to every full-set `#Preview` container (notably `ClassSessionView`, plus `ContentView`, `RootView`, `TodayClassesView`, `SessionHistoryView`)

## 3. Attendance list on the session detail

- [x] 3.1 Create `Views/SessionAttendanceListView.swift` — `init(sessionID: UUID)` owning `@Query(filter: #Predicate<SessionAttendance> { $0.sessionID == sessionID })`; list attendees rendered from snapshot (member name + dog name); empty state; `.onDelete` to remove
- [x] 3.2 Add an "Add participant" affordance opening `AddParticipantView` as a `.sheet`
- [x] 3.3 Replace the placeholder in `ClassSessionView` with `SessionAttendanceListView(sessionID:)` for both the started-occurrence and history-session paths; keep the definition summary read-only and the "Start Session" action only on unstarted occurrences

## 4. Add participant — list path (works in the simulator)

- [x] 4.1 Create `Views/AddParticipantView.swift` (`.sheet`) with a searchable member list (first name / last name / club id) and, when barcode scanning is available, a "Scan" entry
- [x] 4.2 On selecting a member, compute candidate active combinations not already present; exactly one → record transparently; more than one → present a dog picker; none → show a "no active dog / already recorded" message
- [x] 4.3 Shared helper: create a `SessionAttendance` snapshot from the chosen `Combination` + `sessionID`, de-dupe by `combinationID`, insert, save

## 5. Add participant — QR scan path (device)

- [x] 5.1 Create `Views/MemberScannerView.swift` — `UIViewControllerRepresentable` wrapping `DataScannerViewController(recognizedDataTypes: [.barcode(symbologies: [.qr])])`; a `Coordinator` forwards `RecognizedItem` barcode `payloadStringValue` via a closure; start/stop scanning in lifecycle
- [x] 5.2 Gate the scan entry on `DataScannerViewController.isSupported && .isAvailable` (hidden on the simulator)
- [x] 5.3 On payload: parse the URL and read the `member_id` query parameter (e.g. `URLComponents`); a code with no `member_id` shows a "not recognized" message
- [x] 5.4 Known `member_id` → reuse the section-4 selection logic (one active dog → record; several → dog picker; no active dog → message)
- [x] 5.5 Unknown `member_id` → present the club-membership member editor pre-filled with that club member id to register the new member; on dismissal, return to the add-participant flow

## 6. Camera permission

- [x] 6.1 Add `NSCameraUsageDescription` to `TrainingAssistant/Info.plist`
- [x] 6.2 Handle denied/unavailable camera gracefully (fall back to list selection)

## 7. Verification

- [x] 7.1 Run `openspec validate session-attendance --strict` and fix any issues
- [x] 7.2 Build for an iOS 26 simulator; confirm no schema/migration errors and existing data survives
- [ ] 7.3 Simulator (list path): start a session; add a single-active-dog member → recorded transparently; add a multi-active-dog member → dog prompt; the same member (even with a different dog) is no longer offered / cannot be re-added; remove a participant
- [ ] 7.4 Confirm attendance renders from its snapshot after deleting the underlying member/dog/combination
- [ ] 7.5 Open the same session from history → attendance is shown and manageable; no "Start Session" action; definition summary read-only
- [ ] 7.6 Device: scan a URL QR (`member_id=…`) for a known member → same selection logic; scan an unknown `member_id` → member editor opens pre-filled; scan a non-URL code → "not recognized"; camera-permission prompt appears; scan entry hidden on the simulator
- [ ] 7.7 Confirm all new views' SwiftUI `#Preview`s render

## 8. Post-review fixes

- [x] 8.1 Hoist the add-participant sheet from the attendance List section to the session detail (fixes first-open auto-dismiss)
- [x] 8.2 A member attends a session once — de-dupe by member id; exclude recorded members from the list; reject re-add on scan
- [x] 8.3 A dog trains with one member per session — exclude dogs already present from the choices and from the member list; guard on record
- [ ] 8.4 Re-verify in the simulator: the same member is not re-addable, and a dog already present is not offered to another member
