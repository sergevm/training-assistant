//
//  Combination.swift
//  TrainingAssistant
//
//  A global pairing of a member and a dog — the many-to-many join between
//  Member and Dog. Kept as an explicit model (rather than an implicit
//  relationship) so a pairing has a stable id that session attendance can
//  reference and snapshot in a later change.
//

import Foundation
import SwiftData

@Model
final class Combination {
    var id: UUID = UUID()

    /// The paired member and dog. Plain to-one properties (default `.nullify`),
    /// so deleting a combination only unlinks — it never deletes the member or
    /// dog. The inverse to-many lives on `Member.combinations` / `Dog.combinations`.
    var member: Member?
    var dog: Dog?

    init(id: UUID = UUID(), member: Member? = nil, dog: Dog? = nil) {
        self.id = id
        self.member = member
        self.dog = dog
    }
}
