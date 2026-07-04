//
//  Dog.swift
//  TrainingAssistant
//
//  A dog that trains at the school. A dog can be shared across members, so it
//  owns a set of combinations rather than referencing a single member. The
//  active flag marks dogs currently in training and drives transparent
//  selection when a member trains exactly one active dog.
//

import Foundation
import SwiftData

@Model
final class Dog {
    var id: UUID = UUID()
    var name: String = ""
    /// Optional free-text breed for now; a future change will replace this with
    /// a reference to an official breed list.
    var breed: String = ""
    /// Optional date of birth (nil when unknown).
    var dateOfBirth: Date? = nil
    var isActive: Bool = true

    /// Pairings of this dog with the members who train it. Deleting the dog
    /// cascades to its combinations; the paired members are left intact.
    @Relationship(deleteRule: .cascade, inverse: \Combination.dog)
    var combinations: [Combination] = []

    init(id: UUID = UUID(), name: String = "", breed: String = "", dateOfBirth: Date? = nil, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.breed = breed
        self.dateOfBirth = dateOfBirth
        self.isActive = isActive
    }
}
