//
//  CombinationEditorView.swift
//  TrainingAssistant
//
//  Create or edit a Combination (handler + dog + optional current class).
//  Used as a sheet to create (with its own Cancel/Save toolbar) and pushed
//  via navigationDestination(item:) to edit (commits on disappear), per
//  CombinationsView.
//

import SwiftUI
import SwiftData

struct CombinationEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \TrainingClass.name) private var classes: [TrainingClass]

    /// The combination being edited; nil while creating a new one.
    private let existing: Combination?

    @State private var handlerFirstName: String
    @State private var handlerLastName: String
    @State private var dogName: String
    @State private var dogBirthDate: Date
    @State private var dogGender: DogGender
    @State private var notes: String
    @State private var currentClass: TrainingClass?

    init(combination: Combination? = nil) {
        existing = combination
        _handlerFirstName = State(initialValue: combination?.handlerFirstName ?? "")
        _handlerLastName = State(initialValue: combination?.handlerLastName ?? "")
        _dogName = State(initialValue: combination?.dogName ?? "")
        _dogBirthDate = State(initialValue: combination?.dogBirthDate ?? .now)
        _dogGender = State(initialValue: combination?.dogGender ?? .male)
        _notes = State(initialValue: combination?.notes ?? "")
        _currentClass = State(initialValue: combination?.currentClass)
    }

    private var isCreating: Bool { existing == nil }

    private var trimmedHandlerFirstName: String { handlerFirstName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedHandlerLastName: String { handlerLastName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedDogName: String { dogName.trimmingCharacters(in: .whitespacesAndNewlines) }

    private var isValid: Bool {
        !trimmedHandlerFirstName.isEmpty && !trimmedHandlerLastName.isEmpty && !trimmedDogName.isEmpty
    }

    private var navigationTitleText: String {
        guard let existing else { return "New Combination" }
        return existing.dogName.isEmpty ? "Combination" : existing.dogName
    }

    var body: some View {
        Form {
            Section("Handler") {
                TextField("First name", text: $handlerFirstName)
                TextField("Last name", text: $handlerLastName)
            }

            Section("Dog") {
                TextField("Name", text: $dogName)
                DatePicker("Date of birth", selection: $dogBirthDate, in: ...Date.now, displayedComponents: .date)
                Picker("Gender", selection: $dogGender) {
                    ForEach(DogGender.allCases) { gender in
                        Text(gender.displayName).tag(gender)
                    }
                }
            }

            Section("Class") {
                Picker("Current class", selection: $currentClass) {
                    Text("Unassigned").tag(nil as TrainingClass?)
                    ForEach(classes) { trainingClass in
                        Text(trainingClass.name).tag(trainingClass as TrainingClass?)
                    }
                }
            }

            Section("Notes") {
                TextField("Additional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle(navigationTitleText)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isCreating {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { create() }
                        .disabled(!isValid)
                }
            }
        }
        .onDisappear {
            if !isCreating { commit() }
        }
    }

    private func create() {
        guard isValid else { return }
        let combination = Combination(
            handlerFirstName: trimmedHandlerFirstName,
            handlerLastName: trimmedHandlerLastName,
            dogName: trimmedDogName,
            dogBirthDate: dogBirthDate,
            dogGender: dogGender,
            notes: notes,
            currentClass: currentClass
        )
        modelContext.insert(combination)
        try? modelContext.save()
        dismiss()
    }

    /// Persist edits to the existing combination, but only if required fields
    /// are still valid; otherwise leave the stored record untouched.
    private func commit() {
        guard let existing, isValid else { return }
        existing.handlerFirstName = trimmedHandlerFirstName
        existing.handlerLastName = trimmedHandlerLastName
        existing.dogName = trimmedDogName
        existing.dogBirthDate = dogBirthDate
        existing.dogGender = dogGender
        existing.notes = notes
        existing.currentClass = currentClass
        try? modelContext.save()
    }
}

#Preview("New") {
    NavigationStack {
        CombinationEditorView()
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, Combination.self], inMemory: true)
}

#Preview("Edit") {
    let combination = Combination(handlerFirstName: "Jane", handlerLastName: "Doe", dogName: "Rex", dogGender: .male)
    return NavigationStack {
        CombinationEditorView(combination: combination)
    }
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, Combination.self], inMemory: true)
}
