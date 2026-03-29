//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var playerName: String = "" /// Added for player name

    var body: some View {
        NavigationStack { /// Use NavigationStack for a single-column game flow
            VStack(spacing: 20) {
                Spacer() /// Pushes content to the middle from the top
                
                Text("Bubble Pop")
                    .font(.system(size: 60, weight: .light, design: .default))
                
                /// Placeholder for Player Name entry
                TextField("Enter your name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                
                NavigationLink(destination: GameView()) {
                    /// Leads into Game Scene
                    Text("Start Game")
                        .fontWeight(.bold)
                        .frame(maxWidth: 200)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
                
                Spacer() // Pushes content to the middle from the bottom
            }
            /// You can keep a small title or hide it
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
