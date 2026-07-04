//
//  TodayClassesView.swift
//  TrainingAssistant
//
//  The day's classes: candidate occurrences derived from the weekly schedule
//  for today, plus sessions already started. A filter switches between classes
//  still to start and classes already started. Tapping a row starts a class
//  (or reopens the existing session) and pushes its detail view.
//

import SwiftUI
import SwiftData

struct TodayClassesView: View {
    @Query(sort: \TrainingClass.name) private var classes: [TrainingClass]
    @Query private var sessions: [ClassSession]

    @State private var filter: Filter = .toStart
    @State private var selectedOccurrence: Occurrence?

    enum Filter: Hashable, CaseIterable {
        case toStart
        case started

        var title: String {
            switch self {
            case .toStart: "To start"
            case .started: "Started"
            }
        }
    }

    var body: some View {
        Group {
            if todaysOccurrences.isEmpty {
                ContentUnavailableView {
                    Label("No Classes Today", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("No classes are scheduled for today. Set up classes and their weekly schedule in Settings.")
                }
            } else {
                List {
                    if filteredOccurrences.isEmpty {
                        ContentUnavailableView {
                            Label(emptyFilterTitle, systemImage: "calendar")
                        } description: {
                            Text(emptyFilterMessage)
                        }
                    } else {
                        ForEach(filteredOccurrences) { occurrence in
                            Button {
                                selectedOccurrence = occurrence
                            } label: {
                                OccurrenceRow(occurrence: occurrence)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .navigationTitle("Today")
        // Navigation is driven by @State, not the list rows, so a session that
        // leaves the current filter mid-visit doesn't pop the pushed detail.
        .navigationDestination(item: $selectedOccurrence) { occurrence in
            ClassSessionView(occurrence: occurrence)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Show", selection: $filter) {
                    ForEach(Filter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    // MARK: - Occurrences

    private var todaysOccurrences: [Occurrence] {
        Occurrence.occurrences(for: .now, classes: classes, sessions: sessions)
    }

    private var filteredOccurrences: [Occurrence] {
        todaysOccurrences.filter { filter == .started ? $0.isStarted : !$0.isStarted }
    }

    private var emptyFilterTitle: String {
        filter == .started ? "No Classes Started" : "Nothing Left to Start"
    }

    private var emptyFilterMessage: String {
        filter == .started
            ? "You haven't started any of today's classes yet."
            : "Every class scheduled for today has already been started."
    }
}

private struct OccurrenceRow: View {
    let occurrence: Occurrence

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(occurrence.trainingClass.name)
                Text(occurrence.scheduleEntry.startTimeDisplay)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            statusBadge
        }
        // Make the whole row tappable, not just the text/badge — the Spacer gap
        // is otherwise not hittable under .buttonStyle(.plain).
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var statusBadge: some View {
        if occurrence.isStarted {
            Label("Started", systemImage: "play.circle.fill")
                .labelStyle(.iconOnly)
                .foregroundStyle(.green)
        } else if isOverdue {
            Text("Overdue")
                .font(.caption.weight(.medium))
                .foregroundStyle(.orange)
        }
    }

    /// Slot start time has passed today but the class hasn't been started.
    private var isOverdue: Bool {
        let now = Calendar.current.dateComponents([.hour, .minute], from: .now)
        let minutesNow = (now.hour ?? 0) * 60 + (now.minute ?? 0)
        return occurrence.startMinuteOfDay < minutesNow
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    // A class scheduled for today and one for "tomorrow" so the list is non-empty.
    let todayWeekday = Calendar.current.component(.weekday, from: .now)
    let puppy = TrainingClass(name: "Puppy Class")
    puppy.schedule = [
        ScheduleEntry(dayOfWeek: todayWeekday, startHour: 9, startMinute: 0, trainingClass: puppy),
        ScheduleEntry(dayOfWeek: todayWeekday, startHour: 18, startMinute: 30, trainingClass: puppy)
    ]
    container.mainContext.insert(puppy)

    return NavigationStack {
        TodayClassesView()
    }
    .modelContainer(container)
}
