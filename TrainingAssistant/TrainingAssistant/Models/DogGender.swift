//
//  DogGender.swift
//  TrainingAssistant
//
//  Gender of a dog in a Combination.
//

import Foundation

enum DogGender: Int, CaseIterable, Identifiable {
    case male = 0
    case female = 1

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
