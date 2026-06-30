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
    let container: ModelContainer

    init() {
        container = Self.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }

    /// Open the on-disk store, recreating it if it can't be opened or migrated.
    /// This keeps the app usable across the schema changes of early development:
    /// an incompatible store is replaced rather than silently breaking every save.
    private static func makeContainer() -> ModelContainer {
        let schema = Schema([TrainingClass.self, ScheduleEntry.self, ClassSession.self])
        let configuration = ModelConfiguration(schema: schema)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Could not open/migrate the existing store — remove it and its
            // sidecar files, then start fresh so the app launches and persists.
            let storeURL = configuration.url
            let fileManager = FileManager.default
            for suffix in ["", "-wal", "-shm"] {
                let url = storeURL.deletingLastPathComponent()
                    .appendingPathComponent(storeURL.lastPathComponent + suffix)
                try? fileManager.removeItem(at: url)
            }
            return try! ModelContainer(for: schema, configurations: [configuration])
        }
    }
}
