//
//  ClassSession.swift
//  TrainingAssistant
//
//  A concrete, dated instance of a class — created when a trainer starts a
//  class from its definition and one of its weekly schedule slots. Unlike a
//  ScheduleEntry (a recurring template), a session represents one real
//  occurrence and is the anchor for participants/attendance in later changes.
//
//  A session is intentionally self-contained: it stores the originating ids
//  plus a snapshot of the definition rather than live relationships. That
//  keeps it immune to dangling references (a slot edited or removed after the
//  class was started) and gives a stable summary that won't shift underneath
//  it.
//

import Foundation
import SwiftData

@Model
final class ClassSession {
    var id: UUID = UUID()
    /// The calendar day this session belongs to, normalized to the start of day.
    var date: Date = Date(timeIntervalSince1970: 0)

    /// Identity of the originating definition and slot — plain values, so the
    /// session never holds a relationship that could dangle.
    /// (Defaults keep the schema lightweight-migration-safe.)
    var trainingClassID: UUID = UUID()
    var scheduleEntryID: UUID = UUID()

    /// Display name, defaulted on start to "YY/MM/dd <class name>"; editable later.
    var name: String = ""

    /// Snapshot of the definition captured when the class was started.
    var className: String = ""
    var dayOfWeek: Int = 1
    var startHour: Int = 0
    var startMinute: Int = 0

    init(
        id: UUID = UUID(),
        date: Date,
        trainingClassID: UUID,
        scheduleEntryID: UUID,
        name: String = "",
        className: String,
        dayOfWeek: Int,
        startHour: Int,
        startMinute: Int
    ) {
        self.id = id
        self.date = date
        self.trainingClassID = trainingClassID
        self.scheduleEntryID = scheduleEntryID
        self.name = name
        self.className = className
        self.dayOfWeek = dayOfWeek
        self.startHour = startHour
        self.startMinute = startMinute
    }

    /// The default session name: the date as `YY/MM/dd` followed by the class name.
    static func defaultName(date: Date, className: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return "\(formatter.string(from: date)) \(className)"
    }

    /// Typed accessor for the snapshotted weekday.
    var weekday: Weekday? {
        Weekday(rawValue: dayOfWeek)
    }

    /// Locale-formatted start time (e.g. "9:15 AM" or "09:15").
    var startTimeDisplay: String {
        var components = DateComponents()
        components.hour = startHour
        components.minute = startMinute
        guard let date = Calendar.current.date(from: components) else {
            return String(format: "%02d:%02d", startHour, startMinute)
        }
        return date.formatted(date: .omitted, time: .shortened)
    }
}
