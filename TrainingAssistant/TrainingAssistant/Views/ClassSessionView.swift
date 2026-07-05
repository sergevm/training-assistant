//
//  ClassSessionView.swift
//  TrainingAssistant
//
//  Detail for a class session. Two ways in:
//
//  - From today's classes, driven by a live `Occurrence`: a not-yet-started
//    occurrence shows the concise definition and an explicit "Start Session"
//    action; starting creates the session in place. Whether a session exists is
//    determined by a live @Query keyed on the slot and day, not a snapshot — so
//    creating one updates the view reactively and survives parent re-renders
//    (which would otherwise reset local state and re-show the Start button).
//
//  - From history, driven by a persisted `ClassSession`: the summary is rendered
//    from the session's own stored snapshot, so it displays correctly even if
//    the originating class or slot was later edited or deleted. A session in
//    history is by definition already started, so it always shows the recorded
//    attendance and never the "Start Session" action.
//

import SwiftUI
import SwiftData

struct ClassSessionView: View {
    @Environment(\.modelContext) private var modelContext

    /// What the detail is showing: a computed occurrence (today flow) or a
    /// persisted session opened from history.
    private enum Source {
        case occurrence(Occurrence)
        case session(ClassSession)
    }

    private let source: Source
    /// All sessions for this occurrence's slot, across days. Matched to the
    /// occurrence's day in Swift — `#Predicate` date equality is unreliable
    /// across the in-memory→store round-trip, whereas the `UUID` filter is not.
    /// For the session (history) path this is unused; it's scoped to that
    /// session's own id so the query stays trivial.
    @Query private var slotSessions: [ClassSession]
    @State private var isAddingParticipant = false

    init(occurrence: Occurrence) {
        self.source = .occurrence(occurrence)
        let entryID = occurrence.scheduleEntry.id
        _slotSessions = Query(filter: #Predicate<ClassSession> { $0.scheduleEntryID == entryID })
    }

    init(session: ClassSession) {
        self.source = .session(session)
        let sessionID = session.id
        _slotSessions = Query(filter: #Predicate<ClassSession> { $0.id == sessionID })
    }

    /// The live session for the occurrence path, matched on the occurrence's day.
    private var occurrenceSession: ClassSession? {
        guard case let .occurrence(occurrence) = source else { return nil }
        return slotSessions.first { Calendar.current.isDate($0.date, inSameDayAs: occurrence.date) }
    }

    var body: some View {
        List {
            Section("Class") {
                LabeledContent("Name", value: summaryName)
                LabeledContent("Day", value: summaryDay)
                LabeledContent("Start", value: summaryStart)
            }

            if let session = startedSession {
                SessionAttendanceListView(sessionID: session.id) {
                    isAddingParticipant = true
                }
            } else {
                Section {
                    Button {
                        startSession()
                    } label: {
                        Label("Start Session", systemImage: "play.fill")
                            // Full row width + explicit shape so the whole row
                            // is tappable, not just the label.
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
            }
        }
        .navigationTitle(summaryName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddingParticipant) {
            if let session = startedSession {
                AddParticipantView(sessionID: session.id)
            }
        }
    }

    // MARK: - Summary (rendered from the occurrence definition or the snapshot)

    /// The started session backing what's shown, if any. For the occurrence path
    /// this is the live session for the occurrence's day; for history it's the
    /// session itself. `nil` means a not-yet-started occurrence.
    private var startedSession: ClassSession? {
        switch source {
        case .occurrence: return occurrenceSession
        case let .session(session): return session
        }
    }

    /// The session's name once started, otherwise the default it would receive.
    private var summaryName: String {
        switch source {
        case let .occurrence(occurrence):
            return occurrenceSession?.name
                ?? ClassSession.defaultName(date: occurrence.date, className: occurrence.trainingClass.name)
        case let .session(session):
            return session.name
        }
    }

    private var summaryDay: String {
        switch source {
        case let .occurrence(occurrence):
            return occurrence.scheduleEntry.weekday?.displayName ?? "—"
        case let .session(session):
            return session.weekday?.displayName ?? "—"
        }
    }

    private var summaryStart: String {
        switch source {
        case let .occurrence(occurrence):
            return occurrence.scheduleEntry.startTimeDisplay
        case let .session(session):
            return session.startTimeDisplay
        }
    }

    private func startSession() {
        guard case let .occurrence(occurrence) = source, occurrenceSession == nil else { return }
        let trainingClass = occurrence.trainingClass
        let entry = occurrence.scheduleEntry
        let new = ClassSession(
            date: occurrence.date,
            trainingClassID: trainingClass.id,
            scheduleEntryID: entry.id,
            name: ClassSession.defaultName(date: occurrence.date, className: trainingClass.name),
            className: trainingClass.name,
            dayOfWeek: entry.dayOfWeek,
            startHour: entry.startHour,
            startMinute: entry.startMinute
        )
        modelContext.insert(new)
        try? modelContext.save()
    }
}

#Preview("From occurrence") {
    let container = try! ModelContainer(
        for: TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let puppy = TrainingClass(name: "Puppy Class")
    let entry = ScheduleEntry(dayOfWeek: 3, startHour: 18, startMinute: 30, trainingClass: puppy)
    puppy.schedule = [entry]
    container.mainContext.insert(puppy)

    let occurrence = Occurrence(trainingClass: puppy, scheduleEntry: entry, date: .now, session: nil)

    return NavigationStack {
        ClassSessionView(occurrence: occurrence)
    }
    .modelContainer(container)
}

#Preview("From history session") {
    let container = try! ModelContainer(
        for: TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let session = ClassSession(
        date: .now,
        trainingClassID: UUID(),
        scheduleEntryID: UUID(),
        name: "26/06/24 Puppy Class",
        className: "Puppy Class",
        dayOfWeek: 4,
        startHour: 18,
        startMinute: 30
    )
    container.mainContext.insert(session)

    return NavigationStack {
        ClassSessionView(session: session)
    }
    .modelContainer(container)
}
