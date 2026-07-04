//
//  SessionAttendance.swift
//  TrainingAssistant
//
//  A record that a combination (a member + dog pairing) attended a class
//  session. Like ClassSession, it is a self-contained snapshot: it stores the
//  originating ids plus a snapshot of the member/dog identity rather than live
//  relationships, so the record renders correctly even after the member, dog,
//  or combination is later edited or deleted.
//

import Foundation
import SwiftData

@Model
final class SessionAttendance {
    var id: UUID = UUID()
    /// The session this attendance belongs to — the query key.
    var sessionID: UUID = UUID()
    /// The originating combination — used to de-dupe within a session.
    var combinationID: UUID = UUID()
    /// Reference ids (not relationships), for future correlation.
    var memberID: UUID = UUID()
    var dogID: UUID = UUID()

    /// Snapshot of identity captured when attendance was recorded.
    var clubMemberID: String = ""
    var memberName: String = ""
    var dogName: String = ""
    var recordedAt: Date = Date(timeIntervalSince1970: 0)

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        combinationID: UUID,
        memberID: UUID = UUID(),
        dogID: UUID = UUID(),
        clubMemberID: String = "",
        memberName: String = "",
        dogName: String = "",
        recordedAt: Date = Date(timeIntervalSince1970: 0)
    ) {
        self.id = id
        self.sessionID = sessionID
        self.combinationID = combinationID
        self.memberID = memberID
        self.dogID = dogID
        self.clubMemberID = clubMemberID
        self.memberName = memberName
        self.dogName = dogName
        self.recordedAt = recordedAt
    }

    /// Snapshot attendance for a combination present at a session.
    convenience init(sessionID: UUID, combination: Combination, recordedAt: Date) {
        self.init(
            sessionID: sessionID,
            combinationID: combination.id,
            memberID: combination.member?.id ?? UUID(),
            dogID: combination.dog?.id ?? UUID(),
            clubMemberID: combination.member?.clubMemberID ?? "",
            memberName: combination.member?.fullName ?? "",
            dogName: combination.dog?.name ?? "",
            recordedAt: recordedAt
        )
    }
}
