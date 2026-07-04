//
//  ContentView.swift
//  TrainingAssistant
//
//  Created by Serge Van Meerbeeck on 29/06/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "dog.fill")
                    .imageScale(.large)
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
                Text("Training Assistant")
                    .font(.title2.weight(.semibold))
                Text("Set up your school's classes and weekly schedule in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                NavigationLink {
                    TodayClassesView()
                } label: {
                    Label("Today's Classes", systemImage: "calendar.day.timeline.left")
                }
                .buttonStyle(.borderedProminent)

                NavigationLink {
                    SessionHistoryView()
                } label: {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Training Assistant")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TrainingClass.self, ScheduleEntry.self, ClassSession.self, Member.self, Dog.self, Combination.self], inMemory: true)
}
