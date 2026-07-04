//
//  MemberEditorView.swift
//  TrainingAssistant
//
//  Edit a member: update their details and manage the dogs they train (each
//  pairing is a Combination).
//

import SwiftUI
import SwiftData

struct MemberEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var members: [Member]
    let member: Member

    /// Edited details held locally. The club id is only committed when non-empty
    /// and unique; names are always committed (trimmed). This mirrors the
    /// draft-commit pattern used for class names.
    @State private var draftClubID: String
    @State private var draftFirstName: String
    @State private var draftLastName: String
    @State private var showsDuplicateAlert = false
    @State private var duplicateID = ""
    @State private var isAddingCombination = false

    init(member: Member) {
        self.member = member
        _draftClubID = State(initialValue: member.clubMemberID)
        _draftFirstName = State(initialValue: member.firstName)
        _draftLastName = State(initialValue: member.lastName)
    }

    var body: some View {
        Form {
            Section("Club Member") {
                TextField("Member ID", text: $draftClubID)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .onSubmit { commitDetails(surfaceAlert: true) }
                TextField("First name", text: $draftFirstName)
                    .onSubmit { commitDetails(surfaceAlert: true) }
                TextField("Last name", text: $draftLastName)
                    .onSubmit { commitDetails(surfaceAlert: true) }
            }

            Section("Dogs") {
                if member.combinations.isEmpty {
                    Text("No dogs yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedCombinations) { combination in
                        if let dog = combination.dog {
                            NavigationLink {
                                DogEditorView(dog: dog)
                            } label: {
                                CombinationRow(combination: combination)
                            }
                        } else {
                            CombinationRow(combination: combination)
                        }
                    }
                    .onDelete(perform: deleteCombinations)
                }

                Button {
                    isAddingCombination = true
                } label: {
                    Label("Add Dog", systemImage: "plus")
                }
            }
        }
        .navigationTitle(member.fullName.isEmpty ? "Member" : member.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { commitDetails(surfaceAlert: false) }
        .sheet(isPresented: $isAddingCombination) {
            CombinationEditorView(member: member)
        }
        .alert("Member Already Exists", isPresented: $showsDuplicateAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("A member with id “\(duplicateID)” already exists.")
        }
    }

    /// Commit edited details. The club id must be non-empty and unique (trimmed,
    /// case-sensitive); if it is not, revert the draft club id to the saved value
    /// but still accept the name edits.
    private func commitDetails(surfaceAlert: Bool) {
        let id = draftClubID.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = draftFirstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let last = draftLastName.trimmingCharacters(in: .whitespacesAndNewlines)

        if id.isEmpty {
            draftClubID = member.clubMemberID
        } else if members.contains(where: {
            $0.id != member.id
                && $0.clubMemberID.trimmingCharacters(in: .whitespacesAndNewlines) == id
        }) {
            if surfaceAlert {
                duplicateID = id
                showsDuplicateAlert = true
            }
            draftClubID = member.clubMemberID
        } else {
            member.clubMemberID = id
        }

        member.firstName = first
        member.lastName = last
        draftFirstName = first
        draftLastName = last
        try? modelContext.save()
    }

    /// This member's combinations ordered by dog name.
    private var sortedCombinations: [Combination] {
        member.combinations.sorted {
            ($0.dog?.name ?? "").localizedCaseInsensitiveCompare($1.dog?.name ?? "") == .orderedAscending
        }
    }

    private func deleteCombinations(at offsets: IndexSet) {
        let combinations = sortedCombinations
        for index in offsets {
            let combination = combinations[index]
            let dog = combination.dog
            // Remove the pairing; if the dog now has no other owner, delete it too.
            let dogHasOtherOwner = dog?.combinations.contains { $0.id != combination.id } ?? false
            modelContext.delete(combination)
            if let dog, !dogHasOtherOwner {
                modelContext.delete(dog)
            }
        }
        try? modelContext.save()
    }
}

private struct CombinationRow: View {
    let combination: Combination

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(combination.dog?.name ?? "—")
                if let breed = combination.dog?.breed, !breed.isEmpty {
                    Text(breed)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if combination.dog?.isActive == false {
                Text("Inactive")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MemberEditorView(member: Member(clubMemberID: "M-001", firstName: "Ada", lastName: "Lovelace"))
    }
    .modelContainer(for: [Member.self, Dog.self, Combination.self], inMemory: true)
}
