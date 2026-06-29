//
//  TrainingAssistantApp.swift
//  TrainingAssistant
//
//  Created by Serge Van Meerbeeck on 29/06/2026.
//

import SwiftUI
import SwiftData

@main
struct TrainingAssistantApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [TrainingClass.self, ScheduleEntry.self])
    }
}
