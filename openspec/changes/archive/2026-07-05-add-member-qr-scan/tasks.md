## 1. Shared QR payload parser

- [x] 1.1 Add a `MemberQRCode` enum in `MemberScannerView.swift` with a static
      `memberID(fromURL:)` that extracts the trimmed, non-empty `member_id` query parameter
      from a URL payload (moved from `AddParticipantView`)
- [x] 1.2 Update `AddParticipantView.handleScan` to call `MemberQRCode.memberID(fromURL:)` and
      delete its private static helper

## 2. Scan from the add-member sheet

- [x] 2.1 In `AddMemberView` (`MembersView.swift`), add a "Scan Member QR" section shown only
      when `DataScannerViewController.isSupported && .isAvailable` (import VisionKit)
- [x] 2.2 Present `MemberScannerView` in a `fullScreenCover` with a `NavigationStack`, inline
      title, and Cancel button, matching `AddParticipantView.scannerCover`
- [x] 2.3 Handle the scanned payload: invalid payload → "not a valid member QR code" alert;
      duplicate id (trimmed, case-sensitive against existing members) → existing
      "Member Already Exists" alert; otherwise pre-fill the club member id field

## 3. Verify

- [x] 3.1 Build the app and run unit checks of the parser behavior (valid, missing param,
      blank param, non-URL payload)
- [x] 3.2 Confirm the simulator hides the scan button and the manual add path is unchanged
