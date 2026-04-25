//
//  HighScoreView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct HighScoreView: View {
    @Environment(ScoreManager.self) private var scoreManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            bubbleBackground
            
            VStack(spacing: 0) {
                Text("Leaderboard")
                    .font(.system(size: 50, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                
                if scoreManager.allScores.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .green],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        Text("No scores yet.")
                            .font(.system(.title2, design: .rounded).bold())
                        Text("Start popping!")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(scoreManager.allScores.enumerated()), id: \.element.id) { index, entry in
                            HStack(spacing: 16) {
                                /// Rank number
                                Text("\(index + 1)")
                                    .font(.system(size: 28, weight: .black, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .frame(width: 36, alignment: .center)
                                
                                /// Player name
                                Text(entry.playerName)
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(entry.score) pts")
                                    .font(.subheadline.monospacedDigit())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.orange.opacity(0.15))
                                    )
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.white.opacity(0.6))
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                }
            }
    
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    scoreManager.resetLeaderboard()
                } label: {
                    Text("Clear")
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.regularMaterial, in: Capsule())
                }
                .disabled(scoreManager.allScores.isEmpty)
            }
        }
    }
    
    private var bubbleBackground: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -120, y: -300)
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 130, y: -100)
            Circle()
                .fill(Color.pink.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -80, y: 300)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    NavigationStack {
        HighScoreView()
            .environment(ScoreManager())
    }
}
