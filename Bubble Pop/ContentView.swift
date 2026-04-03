//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var playerName: String = "" /// To add player name

    var body: some View {
        NavigationStack { /// Use NavigationStack for a single-column game flow
            ZStack {
                /// Full Screen Seamless Background
                Color.white.opacity(0.95).ignoresSafeArea()
                
                /// The Redesigned Content Card
                VStack(spacing: 35) {
                    
                    Spacer() /// Pushes content to the center from top
                    
                    /// App Title (Updated Typography to match end screen design)
                    Text("Bubble Pop")
                        .font(.system(size: 48, weight: .heavy, design: .rounded))
                        .foregroundColor(.primary)
                    
                    /// User Input Section
                    VStack(spacing: 12) {
                        Text("PLAYER NAME")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(2)
                        
                        TextField("Enter your name", text: $playerName)
                            .font(.system(.headline, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: 55)
                            /// "Frosted glass" field aesthetic
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
                            .padding(.horizontal, 40)
                    }
                    
                    /// Custom Pill Action Button
                    NavigationLink(destination: GameView()) {
                        Text("Start Game")
                            .font(.system(.headline, design: .rounded).bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(playerName.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                        /// Subtle shadow to match restart button
                            .shadow(color: playerName.isEmpty ? .clear : .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 40)
                    /// Disables start until a name is entered
                    .disabled(playerName.isEmpty)
                    
                    Spacer() /// Pushes content to the center from bottom
                }
                .padding(40)
                /// Added "Apple" Materials look to the card itself
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 25, x: 0, y: 15)
                .padding(.horizontal, 25)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true) /// Keeps look minimal
        }
    }
}

#Preview {
    ContentView()
        .environment(PlayerData())
        .environment(ScoreManager())
        .modelContainer(for: Item.self, inMemory: true)
}
