//
//  Member.swift
//  TrainingAssistant
//
//  A club member (a person). Identified by an externally-assigned club member
//  id — the value encoded in the member's QR code — plus a name. A member can
//  train several dogs, so it owns a set of combinations (member + dog pairings)
//  rather than referencing a single dog.
//

import Foundation
import SwiftData

@Model
final class Member {
    var id: UUID = UUID()
    /// Externally-assigned club id, encoded in the member's QR code. Distinct
    /// from `id` (the surrogate key) and kept unique across members.
    var clubMemberID: String = ""
    var firstName: String = ""
    var lastName: String = ""

    /// Pairings of this member with the dogs they train. Deleting the member
    /// cascades to its combinations (a pairing without a member is meaningless);
    /// the paired dogs are left intact.
    @Relationship(deleteRule: .cascade, inverse: \Combination.member)
    var combinations: [Combination] = []

    init(id: UUID = UUID(), clubMemberID: String = "", firstName: String = "", lastName: String = "") {
        self.id = id
        self.clubMemberID = clubMemberID
        self.firstName = firstName
        self.lastName = lastName
    }

    /// "First Last", trimmed of surrounding whitespace.
    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    /// Combinations whose dog is currently active — the candidates for session
    /// attendance selection.
    var activeCombinations: [Combination] {
        combinations.filter { $0.dog?.isActive == true }
    }
}
