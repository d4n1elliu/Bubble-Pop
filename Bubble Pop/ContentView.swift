//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var playerName: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 35) {
                Spacer()
                
                /// Game title 
                Text("Bubble Pop")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                
                /// Enter player name inputs
                VStack(spacing: 12) {
                    Text("PLAYER NAME")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)
                        .tracking(2)
                    
                    TextField("Enter your name", text: $playerName)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(height: 55)
                        .background(Color.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 15))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(.horizontal, 70)
                }
                
                /// Start game button
                NavigationLink(destination: GameView()) {
                    Text("Start Game")
                        .font(.system(.headline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: playerName.isEmpty ? .clear : .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 70)
                .disabled(playerName.isEmpty)
                
                Spacer()
            }
            .padding(40)
            
            /// Navigation modifiers belong INSIDE the stack on the main view
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}

/// Rendering for app preview 
#Preview {
    ContentView()
        .environment(PlayerData())
        .environment(ScoreManager())
        .modelContainer(for: Item.self, inMemory: true)
}
