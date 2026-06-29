//
//  ScheduleEntry.swift
//  TrainingAssistant
//
//  A single weekly recurring occurrence of a class: a day of the week and
//  a start hour. Duration is fixed at one hour and is therefore not stored.
//

import Foundation
import SwiftData

@Model
final class ScheduleEntry {
    var id: UUID
    /// Calendar weekday convention: 1 = Sunday … 7 = Saturday.
    var dayOfWeek: Int
    /// Start hour in 24-hour form, 0...23. Implies a one-hour class.
    var startHour: Int
    /// Start minute on a quarter-hour boundary: one of 0, 15, 30, 45.
    var startMinute: Int = 0

    var trainingClass: TrainingClass?

    init(id: UUID = UUID(), dayOfWeek: Int, startHour: Int, startMinute: Int = 0, trainingClass: TrainingClass? = nil) {
        self.id = id
        self.dayOfWeek = dayOfWeek
        self.startHour = startHour
        self.startMinute = startMinute
        self.trainingClass = trainingClass
    }

    /// Typed accessor for the stored weekday.
    var weekday: Weekday? {
        Weekday(rawValue: dayOfWeek)
    }

    /// Locale-formatted start time (e.g. "9:15 AM" or "09:15") derived from `startHour`/`startMinute`.
    var startTimeDisplay: String {
        var components = DateComponents()
        components.hour = startHour
        components.minute = startMinute
        guard let date = Calendar.current.date(from: components) else {
            return String(format: "%02d:%02d", startHour, startMinute)
        }
        return date.formatted(date: .omitted, time: .shortened)
    }

    /// Minutes since midnight — convenient for sorting and picker round-tripping.
    var startMinuteOfDay: Int { startHour * 60 + startMinute }
}
