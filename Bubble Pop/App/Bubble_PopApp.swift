//
//  Bubble_PopApp.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

@main
struct Bubble_PopApp: App {
    @State private var scoreManager = ScoreManager()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(scoreManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
