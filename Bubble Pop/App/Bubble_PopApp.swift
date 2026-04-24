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
    /// Store player related data (e.g. name, settings) and shared across the entire app via SwiftUI environment.
    @State private var playerData = PlayerData()
    
    /// Managing score tracking and high score logic which also is shared via the environment
    @State private var scoreManager = ScoreManager()
    
    /// Configure and creates SwiftData persistent storage container.
    var sharedModelContainer: ModelContainer = {
        /// Define data schema using models that the app requires to persists
        let schema = Schema([
            Item.self,
        ])
        
        /// Configure the model store, 'isStoredInMemoryOnly'
        /// false means data will persist to disk across app launches.
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            /// Attempts to create container with defined schema and config
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            /// If container cannot be created, then crash immediately with a clear error
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(playerData)
                .environment(scoreManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
