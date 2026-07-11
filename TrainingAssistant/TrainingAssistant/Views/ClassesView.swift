//
//  ClassesView.swift
//  TrainingAssistant
//
//  Manage the school's classes and their weekly schedules. Reachable from
//  the hamburger menu on the primary screens.
//

import SwiftUI
import SwiftData

struct ClassesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TrainingClass.name) private var classes: [TrainingClass]

    @State private var isAddingClass = false
    @State private var newClassName = ""
    @State private var showsDuplicateAlert = false

    var body: some View {
        List {
            if classes.isEmpty {
                Text("No classes yet. Tap + to add one.")
                    .foregroundStyle(.secondary)
            } else {
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
        .alert("Class Already Exists", isPresented: $showsDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A class named “\(trimmedNewName)” already exists.")
        }
    }

    private var trimmedNewName: String {
        newClassName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A class with the same name already exists (compared case-insensitively, trimmed).
    private var isDuplicateName: Bool {
        let candidate = trimmedNewName.lowercased()
        return classes.contains { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == candidate }
    }

    private func startAddingClass() {
        newClassName = ""
        isAddingClass = true
    }

    private func addClass() {
        let name = trimmedNewName
        guard !name.isEmpty else { return }
        guard !isDuplicateName else {
            showsDuplicateAlert = true
            return
        }
        modelContext.insert(TrainingClass(name: name))
        try? modelContext.save()
        newClassName = ""
    }

    private func deleteClasses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(classes[index])
        }
        try? modelContext.save()
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
        ClassesView()
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self], inMemory: true)
}
