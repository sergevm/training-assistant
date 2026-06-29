//
//  ClassEditorView.swift
//  TrainingAssistant
//
//  Edit a class: rename it and manage its weekly schedule entries.
//

import SwiftUI
import SwiftData

struct ClassEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trainingClass: TrainingClass

    @State private var isAddingEntry = false

    var body: some View {
        Form {
            Section("Name") {
                TextField("Class name", text: $trainingClass.name)
            }

            Section("Weekly Schedule") {
                if sortedSchedule.isEmpty {
                    Text("No sessions yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedSchedule) { entry in
                        ScheduleEntryRow(entry: entry)
                    }
                    .onDelete(perform: deleteEntries)
                }

                Button {
                    isAddingEntry = true
                } label: {
                    Label("Add Session", systemImage: "plus")
                }
            }
        }
        .navigationTitle(trainingClass.name.isEmpty ? "Class" : trainingClass.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddingEntry) {
            ScheduleEntryEditorView(trainingClass: trainingClass)
        }
    }

    /// Schedule ordered by day-of-week then start hour.
    private var sortedSchedule: [ScheduleEntry] {
        trainingClass.schedule.sorted {
            if $0.dayOfWeek != $1.dayOfWeek { return $0.dayOfWeek < $1.dayOfWeek }
            return $0.startMinuteOfDay < $1.startMinuteOfDay
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        let entries = sortedSchedule
        for index in offsets {
            modelContext.delete(entries[index])
        }
    }
}

private struct ScheduleEntryRow: View {
    let entry: ScheduleEntry

    var body: some View {
        HStack {
            Text(entry.weekday?.displayName ?? "—")
            Spacer()
            Text(entry.startTimeDisplay)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        ClassEditorView(trainingClass: TrainingClass(name: "Puppy Class"))
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self], inMemory: true)
}
