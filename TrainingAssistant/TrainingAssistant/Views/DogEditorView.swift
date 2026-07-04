//
//  DogEditorView.swift
//  TrainingAssistant
//
//  Edit a dog: its name, breed, date of birth, and whether it is active.
//  Reached by tapping a dog in a member's list — dogs are never managed
//  standalone.
//

import SwiftUI
import SwiftData

struct DogEditorView: View {
    @Environment(\.modelContext) private var modelContext
    let dog: Dog

    /// Name is held locally and only committed when non-empty, so a blank name
    /// is never written. Breed is optional and committed as-is (trimmed).
    @State private var draftName: String
    @State private var draftBreed: String

    init(dog: Dog) {
        self.dog = dog
        _draftName = State(initialValue: dog.name)
        _draftBreed = State(initialValue: dog.breed)
    }

    var body: some View {
        Form {
            Section("Name") {
                TextField("Dog name", text: $draftName)
                    .onSubmit { commitName() }
            }

            Section("Details") {
                TextField("Breed (optional)", text: $draftBreed)
                    .onSubmit { commitBreed() }

                Toggle("Date of birth known", isOn: dobEnabledBinding)
                if dog.dateOfBirth != nil {
                    DatePicker(
                        "Date of birth",
                        selection: dobBinding,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                }
            }

            Section {
                Toggle("Active", isOn: activeBinding)
            } footer: {
                Text("Inactive dogs stay on record but aren't offered when selecting the dog a member is training.")
            }
        }
        .navigationTitle(dog.name.isEmpty ? "Dog" : dog.name)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            commitName()
            commitBreed()
        }
    }

    /// Commit the edited name if non-empty; otherwise revert to the saved name.
    private func commitName() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            draftName = dog.name
            return
        }
        guard name != dog.name else { return }
        dog.name = name
        try? modelContext.save()
    }

    /// Commit the breed as-is (empty means unspecified).
    private func commitBreed() {
        let breed = draftBreed.trimmingCharacters(in: .whitespacesAndNewlines)
        guard breed != dog.breed else { return }
        dog.breed = breed
        try? modelContext.save()
    }

    /// Persist the active flag immediately when toggled.
    private var activeBinding: Binding<Bool> {
        Binding(
            get: { dog.isActive },
            set: { newValue in
                dog.isActive = newValue
                try? modelContext.save()
            }
        )
    }

    /// Turning the toggle on seeds a date (today by default); turning it off
    /// clears the date of birth.
    private var dobEnabledBinding: Binding<Bool> {
        Binding(
            get: { dog.dateOfBirth != nil },
            set: { isOn in
                dog.dateOfBirth = isOn ? (dog.dateOfBirth ?? Date.now) : nil
                try? modelContext.save()
            }
        )
    }

    private var dobBinding: Binding<Date> {
        Binding(
            get: { dog.dateOfBirth ?? Date.now },
            set: { newValue in
                dog.dateOfBirth = newValue
                try? modelContext.save()
            }
        )
    }
}

#Preview {
    NavigationStack {
        DogEditorView(dog: Dog(name: "Rex", breed: "Labrador"))
    }
    .modelContainer(for: [Member.self, Dog.self, Combination.self], inMemory: true)
}
