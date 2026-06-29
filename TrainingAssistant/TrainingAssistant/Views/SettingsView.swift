//
//  SettingsView.swift
//  TrainingAssistant
//
//  Settings area: manage the school's classes and their schedules.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrainingClass.name) private var classes: [TrainingClass]

    @State private var isAddingClass = false
    @State private var newClassName = ""

    var body: some View {
        Group {
            if classes.isEmpty {
                ContentUnavailableView {
                    Label("No Classes Yet", systemImage: "calendar.badge.plus")
                } description: {
                    Text("Add a class to start setting up your school's weekly schedule.")
                } actions: {
                    Button("Add Class") { startAddingClass() }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(classes) { trainingClass in
                        NavigationLink {
                            ClassEditorView(trainingClass: trainingClass)
                        } label: {
                            ClassRow(trainingClass: trainingClass)
                        }
                    }
                    .onDelete(perform: deleteClasses)
                }
            }
        }
        .navigationTitle("Classes")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    startAddingClass()
                } label: {
                    Label("Add Class", systemImage: "plus")
                }
            }
        }
        .alert("New Class", isPresented: $isAddingClass) {
            TextField("Class name", text: $newClassName)
            Button("Cancel", role: .cancel) { newClassName = "" }
            Button("Add") { addClass() }
                .disabled(trimmedNewName.isEmpty)
        } message: {
            Text("Enter a name for the class.")
        }
    }

    private var trimmedNewName: String {
        newClassName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func startAddingClass() {
        newClassName = ""
        isAddingClass = true
    }

    private func addClass() {
        let name = trimmedNewName
        guard !name.isEmpty else { return }
        modelContext.insert(TrainingClass(name: name))
        newClassName = ""
    }

    private func deleteClasses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(classes[index])
        }
    }
}

private struct ClassRow: View {
    let trainingClass: TrainingClass

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(trainingClass.name)
            let count = trainingClass.schedule.count
            Text(count == 1 ? "1 session / week" : "\(count) sessions / week")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self], inMemory: true)
}
