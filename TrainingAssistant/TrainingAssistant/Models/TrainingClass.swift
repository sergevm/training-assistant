//
//  TrainingClass.swift
//  TrainingAssistant
//
//  A class offered by the dog school, identified by name and owning a
//  set of weekly recurring schedule entries.
//

import Foundation
import SwiftData

@Model
final class TrainingClass {
    var id: UUID
    var name: String

    /// Weekly recurring schedule. Deleting the class cascades to its entries.
    @Relationship(deleteRule: .cascade, inverse: \ScheduleEntry.trainingClass)
    var schedule: [ScheduleEntry]

    init(id: UUID = UUID(), name: String, schedule: [ScheduleEntry] = []) {
        self.id = id
        self.name = name
        self.schedule = schedule
    }
}
