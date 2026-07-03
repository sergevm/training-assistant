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
    @Query private var classes: [TrainingClass]
    let trainingClass: TrainingClass

    @State private var isAddingEntry = false
    /// Edited name is held locally and only committed when valid, so a blank or
    /// duplicate name is never written to the model.
    @State private var draftName: String
    @State private var showsDuplicateAlert = false
    /// The rejected name to show in the duplicate alert (draftName is reverted by then).
    @State private var duplicateName = ""

    init(trainingClass: TrainingClass) {
        self.trainingClass = trainingClass
        _draftName = State(initialValue: trainingClass.name)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Class name", text: $draftName)
                    .onSubmit { commitName(surfaceAlert: true) }
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
        .onDisappear { commitName(surfaceAlert: false) }
        .sheet(isPresented: $isAddingEntry) {
            ScheduleEntryEditorView(trainingClass: trainingClass)
        }
        .alert("Class Already Exists", isPresented: $showsDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A class named “\(duplicateName)” already exists.")
        }
    }

    /// Commit the edited name if it is non-empty and not a duplicate of another
    /// class (trimmed, case-insensitive); otherwise revert to the saved name.
    private func commitName(surfaceAlert: Bool) {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            draftName = trainingClass.name
            return
        }
        let isDuplicate = classes.contains { other in
            other.id != trainingClass.id
                && other.name.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(name) == .orderedSame
        }
        guard !isDuplicate else {
            if surfaceAlert {
                duplicateName = name
                showsDuplicateAlert = true
            }
            draftName = trainingClass.name
            return
        }
        guard name != trainingClass.name else { return }
        trainingClass.name = name
        try? modelContext.save()
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
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, Combination.self], inMemory: true)
}
