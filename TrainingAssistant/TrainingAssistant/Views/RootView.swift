//
//  RootView.swift
//  TrainingAssistant
//
//  The scene's root. Gates the whole app on auth state: signed-in users get the
//  existing `ContentView` unchanged; everyone else gets `LoginView`.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        if authService.isSignedIn {
            ContentView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    RootView()
        .environment(AuthService())
        .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, ClassSession.self], inMemory: true)
}
