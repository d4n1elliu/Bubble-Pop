//
//  HighScoreView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct HighScoreView: View {
    /// Initialize the manager to fetch the saved scores
    ///@State private var manager = LeaderboardManager()
    @Environment(ScoreManager.self) private var scoreManager
    
    var body: some View {
        List {
            
            if scoreManager.allScores.isEmpty {
                VStack {
                    Spacer()
                    Text("No scores yet. Start popping!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            } else {
                ForEach(Array(scoreManager.allScores.enumerated()), id: \.element.id) { index, entry in
                    HStack(spacing: 15) {
                        Text("\(index + 1)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .frame(width: 25, alignment: .leading)
                        
                        Text(entry.playerName)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(entry.score)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("High Scores")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    scoreManager.resetLeaderboard()
                } label: {
                    Text("Clear")
                        .foregroundColor(.red)
                }
                .disabled(scoreManager.allScores.isEmpty)
            }
        }
    }
}
