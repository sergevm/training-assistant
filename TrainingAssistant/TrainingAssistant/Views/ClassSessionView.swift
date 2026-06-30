//
//  ClassSessionView.swift
//  TrainingAssistant
//
//  Detail for a class occurrence. A not-yet-started occurrence shows the
//  concise definition and an explicit "Start Session" action; starting creates
//  the session in place. A started occurrence shows the session summary and a
//  participants list (empty for now — participant data arrives in a later
//  change).
//
//  Whether a session exists is determined by a live @Query keyed on the slot
//  and day, not a snapshot — so creating one updates the view reactively and
//  survives parent re-renders (which would otherwise reset local state and
//  re-show the Start button).
//

import SwiftUI
import SwiftData

struct ClassSessionView: View {
    @Environment(\.modelContext) private var modelContext

    let occurrence: Occurrence
    /// All sessions for this occurrence's slot, across days. Matched to the
    /// occurrence's day in Swift — `#Predicate` date equality is unreliable
    /// across the in-memory→store round-trip, whereas the `UUID` filter is not.
    @Query private var slotSessions: [ClassSession]

    init(occurrence: Occurrence) {
        self.occurrence = occurrence
        let entryID = occurrence.scheduleEntry.id
        _slotSessions = Query(filter: #Predicate<ClassSession> { $0.scheduleEntryID == entryID })
    }

    private var session: ClassSession? {
        slotSessions.first { Calendar.current.isDate($0.date, inSameDayAs: occurrence.date) }
    }

    var body: some View {
        List {
            Section("Class") {
                LabeledContent("Name", value: displayName)
                LabeledContent("Day", value: occurrence.scheduleEntry.weekday?.displayName ?? "—")
                LabeledContent("Start", value: occurrence.scheduleEntry.startTimeDisplay)
            }

            if session == nil {
                Section {
                    Button {
                        startSession()
                    } label: {
                        Label("Start Session", systemImage: "play.fill")
                    }
                }
            } else {
                Section("Participants") {
                    ContentUnavailableView {
                        Label("No Participants", systemImage: "person.2")
                    } description: {
                        Text("Club members participating in this class will appear here.")
                    }
                }
            }
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The session's name once started, otherwise the default it would receive.
    private var displayName: String {
        session?.name ?? ClassSession.defaultName(date: occurrence.date, className: occurrence.trainingClass.name)
    }

    private func startSession() {
        guard session == nil else { return }
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

#Preview {
    let container = try! ModelContainer(
        for: TrainingClass.self, ScheduleEntry.self, ClassSession.self,
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
