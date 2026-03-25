//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var playerName: String = "" // Added for player name

    var body: some View {
        NavigationStack { // Use NavigationStack for a single-column game flow
            VStack(spacing: 20) {
                Spacer() // Pushes content to the middle from the top
                
                Text("Bubble Pop")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Placeholder for Player Name entry
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                
                NavigationLink("Start Game") {
                    // This will eventually lead to your GameView
                    Text("Game Starts Here!")
                }
                .buttonStyle(.borderedProminent)
                
                Spacer() // Pushes content to the middle from the bottom
            }
            // You can keep a small title or hide it
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
