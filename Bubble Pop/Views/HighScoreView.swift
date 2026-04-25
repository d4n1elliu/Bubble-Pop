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
            
            VStack(spacing: HighScoreUI.rootVStackSpacing) {
                Text("Leaderboard")
                    .font(.system(size: HighScoreUI.titleFontSize, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, HighScoreUI.titleHorizontalPadding)
                    .padding(.top, HighScoreUI.titleTopPadding)
                    .padding(.bottom, HighScoreUI.titleBottomPadding)
                if scoreManager.allScores.isEmpty {
                    Spacer()
                    VStack(spacing: HighScoreUI.emptyStateSpacing) {
                        Image(systemName: "trophy")
                            .font(.system(size: HighScoreUI.emptyIconSize))
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
                            HStack(spacing: HighScoreUI.rowHSpacing) {
                                Text("\(index + HighScoreUI.rankIndexOffset)")
                                    .font(.system(size: HighScoreUI.rankFontSize, weight: .black, design: .rounded))
                                    .foregroundColor(.secondary)
                                    .frame(width: HighScoreUI.rankFrameWidth, alignment: .center)
                                Text(entry.playerName)
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(entry.score) pts")
                                    .font(.subheadline.monospacedDigit())
                                    .fontWeight(.semibold)
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, HighScoreUI.scorePillHPadding)
                                    .padding(.vertical, HighScoreUI.scorePillVPadding)
                                    .background(
                                        RoundedRectangle(cornerRadius: HighScoreUI.scorePillCornerRadius)
                                            .fill(Color.orange.opacity(HighScoreUI.scorePillOpacity))
                                    )
                            }
                            .padding(.vertical, HighScoreUI.rowVerticalPadding)
                            .listRowBackground(Color.white.opacity(HighScoreUI.rowBackgroundOpacity))
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
                    HStack(spacing: HighScoreUI.toolbarHStackSpacing) {
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
                        .padding(.horizontal, HighScoreUI.toolbarHPadding)
                        .padding(.vertical, HighScoreUI.toolbarVPadding)
                        .background(.regularMaterial, in: Capsule())
                }
                .disabled(scoreManager.allScores.isEmpty)
            }
        }
    }
    
    private var bubbleBackground: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(HighScoreUI.bgBlueOpacity))
                .frame(width: HighScoreUI.bgCircleLargeSize, height: HighScoreUI.bgCircleLargeSize)
                .blur(radius: HighScoreUI.bgBlurLarge)
                .offset(x: HighScoreUI.bgLargeOffsetX, y: HighScoreUI.bgLargeOffsetY)
            Circle()
                .fill(Color.purple.opacity(HighScoreUI.bgPurpleOpacity))
                .frame(width: HighScoreUI.bgCircleMediumSize, height: HighScoreUI.bgCircleMediumSize)
                .blur(radius: HighScoreUI.bgBlurMedium)
                .offset(x: HighScoreUI.bgMediumOffsetX, y: HighScoreUI.bgMediumOffsetY)
            Circle()
                .fill(Color.pink.opacity(HighScoreUI.bgPinkOpacity))
                .frame(width: HighScoreUI.bgCircleSmallSize, height: HighScoreUI.bgCircleSmallSize)
                .blur(radius: HighScoreUI.bgBlurSmall)
                .offset(x: HighScoreUI.bgSmallOffsetX, y: HighScoreUI.bgSmallOffsetY)
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
