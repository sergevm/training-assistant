//
//  SessionAttendanceListView.swift
//  TrainingAssistant
//
//  The participants section of a started session: the combinations recorded as
//  present, with add and remove. Rendered from each record's snapshot, so it
//  displays correctly even after the underlying member/dog/combination changes.
//  Owns a fixed-`sessionID` query because the session identity is fixed at init.
//  Adding is driven by a closure so the presenting sheet lives on a stable
//  container (the session detail), not on this List section.
//

import SwiftUI
import SwiftData

struct SessionAttendanceListView: View {
    @Environment(\.modelContext) private var modelContext

    let sessionID: UUID
    let onAddParticipant: () -> Void
    @Query private var attendance: [SessionAttendance]

    init(sessionID: UUID, onAddParticipant: @escaping () -> Void) {
        self.sessionID = sessionID
        self.onAddParticipant = onAddParticipant
        _attendance = Query(
            filter: #Predicate<SessionAttendance> { $0.sessionID == sessionID },
            sort: \SessionAttendance.recordedAt
        )
    }

    var body: some View {
        Section("Participants") {
            if attendance.isEmpty {
                Text("No participants yet. Add one below.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(attendance) { record in
                    AttendanceRow(record: record)
                }
                .onDelete(perform: deleteAttendance)
            }

            Button {
                onAddParticipant()
            } label: {
                Label("Add Participant", systemImage: "plus")
            }
        }
    }

    private func deleteAttendance(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(attendance[index])
        }
        try? modelContext.save()
    }
}

private struct AttendanceRow: View {
    let record: SessionAttendance

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(record.memberName.isEmpty ? "Unnamed member" : record.memberName)
            Text(record.dogName.isEmpty ? "—" : record.dogName)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
