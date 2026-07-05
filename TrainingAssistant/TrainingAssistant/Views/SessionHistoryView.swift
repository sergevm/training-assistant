//
//  SessionHistoryView.swift
//  TrainingAssistant
//
//  A running record of every class session that has been started, most recent
//  first. Sessions are grouped into one section per calendar day, with day
//  headers ordered descending; within a day they're ordered by start time.
//
//  The list reads persisted `ClassSession`s directly (not the recurring
//  schedule), so it surfaces sessions from any past day and keeps working even
//  when a session's originating class or slot was later edited or deleted —
//  every row renders from the session's own stored snapshot.
//

import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    /// All sessions, newest day first. Day grouping and intra-day ordering are
    /// done in Swift below — `#Predicate`/date `SortDescriptor` semantics are
    /// unreliable across the in-memory→store round-trip, so `date` descending is
    /// the only ordering we lean on the query for.
    @Query(sort: \ClassSession.date, order: .reverse) private var sessions: [ClassSession]

    @State private var selectedSession: ClassSession?

    var body: some View {
        Group {
            if sessions.isEmpty {
                ContentUnavailableView {
                    Label("No Sessions Yet", systemImage: "clock.arrow.circlepath")
                } description: {
                    Text("Classes you start will be recorded here.")
                }
            } else {
                List {
                    ForEach(groupedByDay, id: \.day) { group in
                        Section(dayHeader(group.day)) {
                            ForEach(group.sessions) { session in
                                Button {
                                    selectedSession = session
                                } label: {
                                    row(session)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        // Selection is driven by @State + navigationDestination(item:), mirroring
        // TodayClassesView — a value-based path of `ClassSession` (a SwiftData
        // @Model reference type) re-triggers the push and loops.
        .navigationDestination(item: $selectedSession) { session in
            ClassSessionView(session: session)
        }
        .appMenuToolbar()
    }

    // MARK: - Grouping

    private struct DayGroup {
        let day: Date
        let sessions: [ClassSession]
    }

    /// Bucket sessions by start-of-day, days descending, sessions within a day
    /// ordered by start time.
    private var groupedByDay: [DayGroup] {
        let calendar = Calendar.current
        let buckets = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.date) }
        return buckets.keys.sorted(by: >).map { day in
            let ordered = buckets[day, default: []].sorted {
                ($0.startHour, $0.startMinute) < ($1.startHour, $1.startMinute)
            }
            return DayGroup(day: day, sessions: ordered)
        }
    }

    private func dayHeader(_ day: Date) -> String {
        day.formatted(date: .abbreviated, time: .omitted)
    }

    // MARK: - Row

    private func row(_ session: ClassSession) -> some View {
        HStack {
            Text(session.name)
            Spacer()
            Text(session.startTimeDisplay)
                .foregroundStyle(.secondary)
        }
        // Make the whole row tappable, not just the text: stretch to the full
        // row width, then give the transparent area an explicit hit shape
        // (a Spacer gap is not hittable under .buttonStyle(.plain)).
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

#Preview {
    let container = try! ModelContainer(
        for: TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: .now)
    func day(_ offset: Int) -> Date { calendar.date(byAdding: .day, value: offset, to: today)! }

    let samples: [(Date, String, Int, Int)] = [
        (day(0), "Puppy Class", 18, 30),
        (day(-1), "Obedience 1", 10, 0),
        (day(-1), "Agility", 14, 15),
        (day(-7), "Puppy Class", 18, 30),
    ]
    for (date, className, hour, minute) in samples {
        let session = ClassSession(
            date: date,
            trainingClassID: UUID(),
            scheduleEntryID: UUID(),
            name: "\(ClassSession.defaultName(date: date, className: className))",
            className: className,
            dayOfWeek: calendar.component(.weekday, from: date),
            startHour: hour,
            startMinute: minute
        )
        container.mainContext.insert(session)
    }

    return NavigationStack {
        SessionHistoryView()
    }
    .modelContainer(container)
}
