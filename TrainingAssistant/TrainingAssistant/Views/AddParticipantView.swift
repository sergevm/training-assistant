//
//  AddParticipantView.swift
//  TrainingAssistant
//
//  Record a combination as present at a session. Two entry paths: scan a member
//  QR code (device only), or pick a member from a searchable list (works in the
//  simulator). Once a member is identified, the dog is selected transparently
//  when the member trains exactly one available active dog, otherwise the user
//  is prompted. Scanning an unknown member id opens a pre-filled member editor
//  to register the member, then returns here.
//

import SwiftUI
import SwiftData
import VisionKit

struct AddParticipantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let sessionID: UUID

    @Query private var members: [Member]
    @Query private var attendance: [SessionAttendance]

    @State private var searchText = ""
    @State private var isScanning = false
    @State private var dogChoiceMember: Member?
    @State private var registeringMember: Member?
    @State private var message: ScanMessage?

    init(sessionID: UUID) {
        self.sessionID = sessionID
        _members = Query(sort: [SortDescriptor(\Member.lastName), SortDescriptor(\Member.firstName)])
        _attendance = Query(filter: #Predicate<SessionAttendance> { $0.sessionID == sessionID })
    }

    var body: some View {
        NavigationStack {
            List {
                if scanningAvailable {
                    Section {
                        Button {
                            isScanning = true
                        } label: {
                            Label("Scan Member QR", systemImage: "qrcode.viewfinder")
                                // Full row width + explicit shape so the whole
                                // row is tappable, not just the label.
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                        }
                    }
                }

                Section("Members") {
                    if filteredMembers.isEmpty {
                        Text("No members. Add members in Settings → Club.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(filteredMembers) { member in
                            Button {
                                selectMember(member)
                            } label: {
                                MemberPickRow(member: member)
                                    // The row is only as wide as its text, so
                                    // stretch it before giving it a hit shape —
                                    // contentShape alone covers just the label.
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Add Participant")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Name or member id")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .navigationDestination(item: $registeringMember) { member in
                MemberEditorView(member: member)
            }
            .confirmationDialog("Which dog?", isPresented: dogChoicePresented, presenting: dogChoiceMember) { member in
                ForEach(availableCombinations(for: member)) { combination in
                    Button(combination.dog?.name ?? "Dog") {
                        record(combination)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: { member in
                Text("\(displayName(member)) trains more than one active dog.")
            }
            .alert(message?.title ?? "", isPresented: messagePresented, presenting: message) { _ in
                Button("OK", role: .cancel) { }
            } message: { msg in
                Text(msg.text)
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

    // MARK: - Selection

    /// Record the member's only available active dog transparently, prompt when
    /// there are several, or explain when there is none.
    private func selectMember(_ member: Member) {
        guard !presentMemberIDs.contains(member.id) else {
            message = ScanMessage(
                title: "Already recorded",
                text: "\(displayName(member)) is already recorded in this session."
            )
            return
        }
        let candidates = availableCombinations(for: member)
        switch candidates.count {
        case 0:
            message = ScanMessage(
                title: "No dog to record",
                text: "\(displayName(member)) has no available dog — their active dogs are already training in this session, or they have none active."
            )
        case 1:
            record(candidates[0])
            dismiss()
        default:
            dogChoiceMember = member
        }
    }

    private func record(_ combination: Combination) {
        guard let memberID = combination.member?.id, let dogID = combination.dog?.id,
              !presentMemberIDs.contains(memberID), !presentDogIDs.contains(dogID) else { return }
        let record = SessionAttendance(sessionID: sessionID, combination: combination, recordedAt: Date.now)
        modelContext.insert(record)
        try? modelContext.save()
    }

    // MARK: - Scan handling

    private func handleScan(_ payload: String) {
        guard let scannedID = Self.memberID(fromURL: payload) else {
            message = ScanMessage(title: "Not recognized", text: "That code isn't a valid member QR code.")
            return
        }
        if let member = members.first(where: {
            $0.clubMemberID.trimmingCharacters(in: .whitespacesAndNewlines) == scannedID
        }) {
            selectMember(member)
        } else {
            // Unknown member id: register the member, then return here.
            let newMember = Member(clubMemberID: scannedID)
            modelContext.insert(newMember)
            try? modelContext.save()
            registeringMember = newMember
        }
    }

    /// Extract the `member_id` query-string parameter from a URL QR payload.
    static func memberID(fromURL payload: String) -> String? {
        guard let components = URLComponents(string: payload),
              let value = components.queryItems?.first(where: { $0.name == "member_id" })?.value
        else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Derived state

    private var scanningAvailable: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    /// Members already recorded present in this session (a member attends once).
    private var presentMemberIDs: Set<UUID> {
        Set(attendance.map(\.memberID))
    }

    /// Dogs already recorded present in this session (a dog trains once per session).
    private var presentDogIDs: Set<UUID> {
        Set(attendance.map(\.dogID))
    }

    /// The member's active combinations whose dog isn't already present, by dog name.
    private func availableCombinations(for member: Member) -> [Combination] {
        member.activeCombinations
            .filter { combination in
                guard let dog = combination.dog else { return false }
                return !presentDogIDs.contains(dog.id)
            }
            .sorted { ($0.dog?.name ?? "").localizedCaseInsensitiveCompare($1.dog?.name ?? "") == .orderedAscending }
    }

    private var filteredMembers: [Member] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return members.filter { member in
            guard !presentMemberIDs.contains(member.id) else { return false }
            guard !availableCombinations(for: member).isEmpty else { return false }
            guard !query.isEmpty else { return true }
            return member.firstName.lowercased().contains(query)
                || member.lastName.lowercased().contains(query)
                || member.clubMemberID.lowercased().contains(query)
        }
    }

    private func displayName(_ member: Member) -> String {
        member.fullName.isEmpty ? "This member" : member.fullName
    }

    private var dogChoicePresented: Binding<Bool> {
        Binding(get: { dogChoiceMember != nil }, set: { if !$0 { dogChoiceMember = nil } })
    }

    private var messagePresented: Binding<Bool> {
        Binding(get: { message != nil }, set: { if !$0 { message = nil } })
    }
}

private struct MemberPickRow: View {
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

private struct ScanMessage: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

#Preview {
    let container = try! ModelContainer(
        for: Member.self, Dog.self, Combination.self, SessionAttendance.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let ada = Member(clubMemberID: "M-001", firstName: "Ada", lastName: "Lovelace")
    let rex = Dog(name: "Rex", breed: "Labrador")
    container.mainContext.insert(ada)
    container.mainContext.insert(rex)
    container.mainContext.insert(Combination(member: ada, dog: rex))

    return AddParticipantView(sessionID: UUID())
        .modelContainer(container)
}
