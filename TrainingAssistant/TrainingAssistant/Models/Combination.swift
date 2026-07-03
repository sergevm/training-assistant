//
//  Combination.swift
//  TrainingAssistant
//
//  A handler-dog pair ("combination") registered with the school. Its
//  current class is a live, current-state relationship — unlike
//  ClassSession's id+snapshot approach — so it tracks the class's live
//  name and is cleared (not deleted) if the class is removed.
//

import Foundation
import SwiftData

@Model
final class Combination {
    var id: UUID = UUID()
    var handlerFirstName: String = ""
    var handlerLastName: String = ""
    var dogName: String = ""
    var dogBirthDate: Date = Date(timeIntervalSince1970: 0)
    var dogGenderRaw: Int = 0
    var notes: String = ""

    /// The class this combination currently trains in, if assigned. Cleared
    /// (not deleted) automatically when the class is deleted — see
    /// `TrainingClass.combinations`'s `.nullify` delete rule.
    var currentClass: TrainingClass?

    init(
        id: UUID = UUID(),
        handlerFirstName: String = "",
        handlerLastName: String = "",
        dogName: String = "",
        dogBirthDate: Date = Date(timeIntervalSince1970: 0),
        dogGender: DogGender = .male,
        notes: String = "",
        currentClass: TrainingClass? = nil
    ) {
        self.id = id
        self.handlerFirstName = handlerFirstName
        self.handlerLastName = handlerLastName
        self.dogName = dogName
        self.dogBirthDate = dogBirthDate
        self.dogGenderRaw = dogGender.rawValue
        self.notes = notes
        self.currentClass = currentClass
    }

    /// Typed accessor for the stored gender.
    var dogGender: DogGender? {
        get { DogGender(rawValue: dogGenderRaw) }
        set { dogGenderRaw = (newValue ?? .male).rawValue }
    }

    var handlerFullName: String {
        "\(handlerFirstName) \(handlerLastName)".trimmingCharacters(in: .whitespaces)
    }
}
