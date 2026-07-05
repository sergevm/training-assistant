//
//  MembersView.swift
//  TrainingAssistant
//
//  Manage the school's club members: list, add, edit, and delete. Each member
//  is identified by a unique club member id.
//

import SwiftUI
import SwiftData
import VisionKit

struct MembersView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Member.lastName), SortDescriptor(\Member.firstName)])
    private var members: [Member]

    @State private var isAddingMember = false
    @State private var searchText = ""

    var body: some View {
        Group {
            if members.isEmpty {
                ContentUnavailableView {
                    Label("No Members Yet", systemImage: "person.2")
                } description: {
                    Text("Add a club member so you can pair them with the dogs they train.")
                } actions: {
                    Button("Add Member") { isAddingMember = true }
                        .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(filteredMembers) { member in
                        NavigationLink {
                            MemberEditorView(member: member)
                        } label: {
                            MemberRow(member: member)
                        }
                    }
                    .onDelete(perform: deleteMembers)
                }
                .searchable(text: $searchText, prompt: "Name or member id")
                .overlay {
                    if filteredMembers.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
        }
        .navigationTitle("Members")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isAddingMember = true
                } label: {
                    Label("Add Member", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingMember) {
            AddMemberView(existingMembers: members)
        }
    }

    /// Members filtered by the search text (first name, last name, or club id).
    private var filteredMembers: [Member] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return members }
        return members.filter {
            $0.firstName.lowercased().contains(query)
                || $0.lastName.lowercased().contains(query)
                || $0.clubMemberID.lowercased().contains(query)
        }
    }

    private func deleteMembers(at offsets: IndexSet) {
        let targets = offsets.map { filteredMembers[$0] }
        for member in targets {
            // A dog owned only by this member becomes an orphan once the member
            // (and its combinations) are gone, so delete it too.
            let orphanedDogs = dogsOrphanedByRemoving(member)
            modelContext.delete(member)
            for dog in orphanedDogs {
                modelContext.delete(dog)
            }
        }
        try? modelContext.save()
    }

    /// Dogs that would have no owner once this member's combinations are gone.
    private func dogsOrphanedByRemoving(_ member: Member) -> [Dog] {
        var seen = Set<UUID>()
        var orphans: [Dog] = []
        for dog in member.combinations.compactMap({ $0.dog }) where seen.insert(dog.id).inserted {
            let hasOtherOwner = dog.combinations.contains { $0.member?.id != member.id }
            if !hasOtherOwner { orphans.append(dog) }
        }
        return orphans
    }
}

private struct MemberRow: View {
    let member: Member

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(member.fullName.isEmpty ? "Unnamed member" : member.fullName)
            Text(member.clubMemberID)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

/// Add-member sheet: a small form capturing the club id and name. The club id
/// must be non-empty and unique (trimmed, case-sensitive — it is an externally
/// issued token, not folded like class names). On devices with a live scanner,
/// scanning the member's QR code pre-fills the club id; the member is still
/// only created when the form is confirmed.
private struct AddMemberView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let existingMembers: [Member]

    @State private var clubMemberID = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var showsDuplicateAlert = false
    @State private var duplicateID = ""
    @State private var showsInvalidScanAlert = false
    @State private var isScanning = false

    var body: some View {
        NavigationStack {
            Form {
                if scanningAvailable {
                    Section {
                        Button {
                            isScanning = true
                        } label: {
                            Label("Scan Member QR", systemImage: "qrcode.viewfinder")
                        }
                    }
                }

                Section("Club Member") {
                    TextField("Member ID", text: $clubMemberID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("First name", text: $firstName)
                    TextField("Last name", text: $lastName)
                }
            }
            .navigationTitle("New Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addMember() }
                        .disabled(trimmedClubID.isEmpty)
                }
            }
            .alert("Member Already Exists", isPresented: $showsDuplicateAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("A member with id “\(duplicateID)” already exists.")
            }
            .alert("Not recognized", isPresented: $showsInvalidScanAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("That code isn't a valid member QR code.")
            }
            .fullScreenCover(isPresented: $isScanning) {
                scannerCover
            }
        }
    }

    private var scannerCover: some View {
        NavigationStack {
            MemberScannerView { payload in
                isScanning = false
                handleScan(payload)
            }
            .ignoresSafeArea()
            .navigationTitle("Scan Member QR")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isScanning = false }
                }
            }
        }
    }

    private var scanningAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    /// Pre-fill the club id from a scanned QR payload. Invalid payloads and
    /// already-registered ids leave the form unchanged and inform the user.
    private func handleScan(_ payload: String) {
        guard let scannedID = MemberQRCode.memberID(fromURL: payload) else {
            showsInvalidScanAlert = true
            return
        }
        guard !isRegistered(scannedID) else {
            duplicateID = scannedID
            showsDuplicateAlert = true
            return
        }
        clubMemberID = scannedID
    }

    private var trimmedClubID: String {
        clubMemberID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isRegistered(_ id: String) -> Bool {
        existingMembers.contains {
            $0.clubMemberID.trimmingCharacters(in: .whitespacesAndNewlines) == id
        }
    }

    private func addMember() {
        let id = trimmedClubID
        guard !id.isEmpty else { return }
        guard !isRegistered(id) else {
            duplicateID = id
            showsDuplicateAlert = true
            return
        }
        let member = Member(
            clubMemberID: id,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        modelContext.insert(member)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    NavigationStack {
        MembersView()
    }
    .modelContainer(for: [Member.self, Dog.self, Combination.self], inMemory: true)
}
