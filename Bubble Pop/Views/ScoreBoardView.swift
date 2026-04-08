//
//  ScoreBoardView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 6/4/2026.
//

import SwiftUI

struct ScoreBoardView: View {
    @Environment(ScoreManager.self) private var scoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(scoreManager.allScores) { entry in
                    HStack {
                        Text(entry.playerName)
                            .font(.headline)
                        Spacer()
                        Text("\(entry.score)")
                            .font(.body.monospacedDigit())
                            .fontWeight(.bold)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ScoreBoardView()
        .environment(ScoreManager())
}
