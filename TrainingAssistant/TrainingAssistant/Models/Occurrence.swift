//
//  Occurrence.swift
//  TrainingAssistant
//
//  An occurrence is a computed (not persisted) value: a class slot that falls
//  on a particular day. It pairs a TrainingClass + ScheduleEntry with a date
//  and, if the class has already been started that day, the matching
//  ClassSession. Occurrences are derived from the recurring schedule on the
//  fly; only started ones are backed by a persisted ClassSession.
//

import Foundation

struct Occurrence: Identifiable, Hashable {
    let trainingClass: TrainingClass
    let scheduleEntry: ScheduleEntry
    /// Start-of-day for the day this occurrence falls on.
    let date: Date
    /// The persisted session, if this occurrence has already been started.
    let session: ClassSession?

    /// Stable identity for a day's slot, independent of whether it's started yet.
    var id: String { "\(scheduleEntry.id.uuidString)@\(date.timeIntervalSince1970)" }

    static func == (lhs: Occurrence, rhs: Occurrence) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }

    var isStarted: Bool { session != nil }

    /// Minutes since midnight of the slot's start — used for ordering.
    var startMinuteOfDay: Int { scheduleEntry.startMinuteOfDay }

    // MARK: - Building

    /// Normalize a reference date to the start of its calendar day.
    static func dayStart(for date: Date, calendar: Calendar = .current) -> Date {
        calendar.startOfDay(for: date)
    }

    /// Build the occurrences for a given day from the classes' weekly schedule,
    /// matching each slot's `dayOfWeek` against the day's Calendar weekday
    /// (1 = Sunday). Each matching slot becomes one occurrence, marked started
    /// when a `ClassSession` already exists for that slot on that day. Result is
    /// ordered by start time.
    static func occurrences(
        for date: Date,
        classes: [TrainingClass],
        sessions: [ClassSession],
        calendar: Calendar = .current
    ) -> [Occurrence] {
        let day = dayStart(for: date, calendar: calendar)
        let weekday = calendar.component(.weekday, from: day)

        var result: [Occurrence] = []
        for trainingClass in classes {
            for entry in trainingClass.schedule where entry.dayOfWeek == weekday {
                let session = sessions.first {
                    $0.scheduleEntryID == entry.id && calendar.isDate($0.date, inSameDayAs: day)
                }
                result.append(
                    Occurrence(trainingClass: trainingClass, scheduleEntry: entry, date: day, session: session)
                )
            }
        }
        return result.sorted { $0.startMinuteOfDay < $1.startMinuteOfDay }
    }
}
