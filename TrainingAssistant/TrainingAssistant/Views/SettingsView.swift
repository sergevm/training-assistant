//
//  SettingsView.swift
//  TrainingAssistant
//
//  Settings hub: entries to the Members and Classes screens, plus sign out.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AuthService.self) private var authService

    @State private var showsSignOutConfirmation = false

    var body: some View {
        List {
            Section("Club") {
                NavigationLink {
                    MembersView()
                } label: {
                    Label("Members", systemImage: "person.2")
                }
            }

            Section("Classes") {
                NavigationLink {
                    ClassesView()
                } label: {
                    Label("Classes", systemImage: "list.bullet.rectangle")
                }
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    showsSignOutConfirmation = true
                } label: {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .confirmationDialog(
            "Sign out of Training Assistant?",
            isPresented: $showsSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task { await authService.signOut() }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Your classes and schedule stay on this device.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AuthService())
    .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self, SessionAttendance.self], inMemory: true)
}
