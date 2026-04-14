//
//  HighScoreView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct HighScoreView: View {
    // Initialize the manager to fetch the saved scores
    @State private var manager = LeaderboardManager()
    
    var body: some View {
        List {
            
            if manager.scores.isEmpty {
                Text("No scores yet. Start popping!")
                    .foregroundColor(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(Array(manager.scores.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(width: 25)
                        
                        Text(entry.playerName)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(entry.score)")
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
    }
}
