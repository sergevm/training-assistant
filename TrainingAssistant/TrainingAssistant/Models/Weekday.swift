//
//  Weekday.swift
//  TrainingAssistant
//
//  Day-of-week model used throughout scheduling. Backed by the
//  `Calendar` weekday convention (1 = Sunday … 7 = Saturday) so the
//  stored Int maps directly to system APIs.
//

import Foundation

enum Weekday: Int, CaseIterable, Identifiable, Comparable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    var id: Int { rawValue }

    /// Localized full name (e.g. "Monday"), respecting the user's calendar/locale.
    var displayName: String {
        let symbols = Calendar.current.weekdaySymbols
        // weekdaySymbols is 0-indexed starting at Sunday; rawValue is 1...7.
        return symbols[rawValue - 1]
    }

    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
