//
//  CombinationEditorView.swift
//  TrainingAssistant
//
//  Add a dog to a member. By default you create a new dog for the member; you
//  can also share a dog owned by another member by looking that member up (so
//  two people — e.g. husband and wife — can own the same dog). Other members'
//  dogs are never offered except through that explicit lookup.
//

import SwiftUI
import SwiftData

struct CombinationEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let member: Member

    private enum Mode: String, CaseIterable, Identifiable {
        case newDog = "New dog"
        case share = "Another member's dog"
        var id: String { rawValue }
    }

    @State private var mode: Mode = .newDog
    @State private var newDogName = ""
    @State private var newDogBreed = ""
    @State private var newDogIsActive = true

    var body: some View {
        NavigationStack {
            Form {
                Picker("Add", selection: $mode) {
                    ForEach(Mode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                switch mode {
                case .newDog:
                    Section("New Dog") {
                        TextField("Dog name", text: $newDogName)
                        TextField("Breed (optional)", text: $newDogBreed)
                        Toggle("Active", isOn: $newDogIsActive)
                    }
                case .share:
                    Section {
                        NavigationLink {
                            MemberDogLookupView(targetMember: member) { dog in
                                pair(with: dog)
                            }
                        } label: {
                            Label("Choose from another member", systemImage: "magnifyingglass")
                        }
                    } footer: {
                        Text("Look up another member to share one of their dogs — e.g. two owners of the same dog.")
                    }
                }
            }
            .navigationTitle("Add Dog")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                if mode == .newDog {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Add") { addNewDog() }
                            .disabled(trimmedNewDogName.isEmpty)
                    }
                }
            }
        }
    }

    private var trimmedNewDogName: String {
        newDogName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addNewDog() {
        let name = trimmedNewDogName
        guard !name.isEmpty else { return }
        let dog = Dog(
            name: name,
            breed: newDogBreed.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: newDogIsActive
        )
        modelContext.insert(dog)
        pair(with: dog)
    }

    /// Create the combination linking the member to the dog, then dismiss. The
    /// no-duplicate-pairing rule is enforced (the lookup already excludes dogs
    /// the member owns, so this mainly guards the shared path).
    private func pair(with dog: Dog) {
        guard !member.combinations.contains(where: { $0.dog?.id == dog.id }) else {
            dismiss()
            return
        }
        modelContext.insert(Combination(member: member, dog: dog))
        try? modelContext.save()
        dismiss()
    }
}

/// Searchable list of the OTHER members (those who own at least one dog), used
/// to share one of their dogs with the target member.
private struct MemberDogLookupView: View {
    let targetMember: Member
    let onPick: (Dog) -> Void

    @Query private var allMembers: [Member]
    @State private var searchText = ""

    init(targetMember: Member, onPick: @escaping (Dog) -> Void) {
        self.targetMember = targetMember
        self.onPick = onPick
        _allMembers = Query(sort: [SortDescriptor(\Member.lastName), SortDescriptor(\Member.firstName)])
    }

    var body: some View {
        List {
            ForEach(matchingMembers) { owner in
                NavigationLink {
                    SharedDogListView(owner: owner, targetMember: targetMember, onPick: onPick)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(owner.fullName.isEmpty ? "Unnamed member" : owner.fullName)
                        Text(owner.clubMemberID)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Choose Member")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Name or member id")
        .overlay {
            if matchingMembers.isEmpty {
                ContentUnavailableView {
                    Label("No Members", systemImage: "person.2")
                } description: {
                    Text("No other member owns a dog available to share.")
                }
            }
        }
    }

    /// Other members (never the target) who own at least one dog, filtered by search.
    private var matchingMembers: [Member] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return allMembers.filter { owner in
            guard owner.id != targetMember.id, !owner.combinations.isEmpty else { return false }
            guard !query.isEmpty else { return true }
            return owner.firstName.lowercased().contains(query)
                || owner.lastName.lowercased().contains(query)
                || owner.clubMemberID.lowercased().contains(query)
        }
    }
}

/// The chosen owner's dogs that the target member isn't already paired with.
private struct SharedDogListView: View {
    let owner: Member
    let targetMember: Member
    let onPick: (Dog) -> Void

    var body: some View {
        List {
            if shareableDogs.isEmpty {
                ContentUnavailableView {
                    Label("No Dogs to Share", systemImage: "dog")
                } description: {
                    Text("This member has no dogs that aren't already paired with the current member.")
                }
            } else {
                ForEach(shareableDogs) { dog in
                    Button {
                        onPick(dog)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(dog.name)
                                if !dog.breed.isEmpty {
                                    Text(dog.breed)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                            if !dog.isActive {
                                Text("Inactive")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle(owner.fullName.isEmpty ? "Dogs" : owner.fullName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var shareableDogs: [Dog] {
        let alreadyPaired = Set(targetMember.combinations.compactMap { $0.dog?.id })
        var seen = Set<UUID>()
        var dogs: [Dog] = []
        for dog in owner.combinations.compactMap({ $0.dog }) where !alreadyPaired.contains(dog.id) && seen.insert(dog.id).inserted {
            dogs.append(dog)
        }
        return dogs.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Member.self, Dog.self, Combination.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ada = Member(clubMemberID: "M-001", firstName: "Ada", lastName: "Lovelace")
    let alan = Member(clubMemberID: "M-002", firstName: "Alan", lastName: "Turing")
    let rex = Dog(name: "Rex", breed: "Labrador")
    container.mainContext.insert(ada)
    container.mainContext.insert(alan)
    container.mainContext.insert(rex)
    container.mainContext.insert(Combination(member: alan, dog: rex))

    return CombinationEditorView(member: ada)
        .modelContainer(container)
}
