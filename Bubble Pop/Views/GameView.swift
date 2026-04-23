//
//  GameView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 8/4/2026.
//

import SwiftUI
import SpriteKit

/// The root view for the bubble-popping game, bridging SpriteKit and SwiftUI.
struct GameView: View {
    let playerName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData
    @Environment(ScoreManager.self) private var scoreManager

    @State private var showReturnButton = false
    @State private var showScoreBoard = false
    @State private var viewModel: GameViewModel?
    @State private var isCountingDown = true
    
    @AppStorage("gameTimeframe") private var timeframe = 60
    @AppStorage("maxBubbles") private var maximumBubbles = 15

    @State private var gameScene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }()

    var body: some View {
        VStack(spacing: 0) {
            /// HUD
            HStack {
                statColumn(title: "Time Left", value: "\(viewModel?.playTime ?? timeframe)", color: (viewModel?.playTime ?? timeframe) <= 10 ? .red : .primary)
                    .frame(maxWidth: .infinity)
                statColumn(title: "Score", value: "\(playerData.currentScore)")
                    .frame(maxWidth: .infinity)
                statColumn(title: "High Score", value: "\(scoreManager.highScore)")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.ultraThinMaterial)

            /// Game Layer
            GeometryReader { geo in
                ZStack {
                    
                    /// Gradient background matching onboarding aesthetic
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.87, green: 0.85, blue: 0.75), location: 0.0),
                            .init(color: Color(red: 0.50, green: 0.72, blue: 0.78), location: 0.5),
                            .init(color: Color(red: 0.45, green: 0.34, blue: 0.67), location: 1.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    SpriteView(scene: gameScene, options: [.allowsTransparency, .ignoresSiblingOrder])
                        .onAppear {
                            gameScene.size = geo.size
                            gameScene.removeAllChildren()
                            setupGame()
                        }
                        .onChange(of: geo.size) { _, newSize in
                            gameScene.size = newSize
                        }

                    if isCountingDown {
                        CountdownOverlayView {
                            withAnimation { isCountingDown = false }
                            viewModel?.startGame()
                        }
                        .transition(.opacity)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if showReturnButton { endGameOverlay }
        }
        .sheet(isPresented: $showScoreBoard) {
            NavigationStack {
                HighScoreView()
            }
            .environment(scoreManager)
        }
    }

    private func statColumn(title: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: 6) {
            Text(title).font(.system(size: 20, weight: .semibold))
            Text(value).font(.system(size: 25, weight: .medium, design: .monospaced)).foregroundColor(color)
        }
    }

    private func setupGame() {
        if viewModel == nil {
            viewModel = GameViewModel(player: playerData, scoreManager: scoreManager)
        }

        guard let gc = viewModel else { return }

        gc.configure(time: timeframe, maxBubbles: maximumBubbles, scene: gameScene)

        gameScene.isPaused = false
        showReturnButton = false
        gameScene.playerName = playerName

        gameScene.onReturnHome = {
            DispatchQueue.main.async {
                withAnimation(.spring()) {
                    self.showReturnButton = true
                    self.scoreManager.updateHighScore(with: self.playerData.currentScore, playerName: self.playerName)
                }
            }
        }
    }

    private var endGameOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().transition(.opacity)

            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text(viewModel?.playTime ?? 0 <= 0 ? "TIME'S UP!" : "GAME OVER")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                    Text(playerName.uppercased())
                        .font(.headline).foregroundColor(.secondary)
                }

                VStack(spacing: 4) {
                    Text("FINAL SCORE").font(.caption).bold().tracking(2)
                    Text("\(playerData.currentScore)").font(.system(size: 70, weight: .black, design: .rounded))
                }

                VStack(spacing: 12) {
                    buttonCapsule("Restart Game", color: .blue) {
                        playerData.currentScore = 0
                        showReturnButton = false
                        gameScene.restartGameSession()
                    }
                    buttonCapsule("Scoreboard", color: .orange) {
                        showScoreBoard = true
                    }
                    buttonCapsule("Main Menu", color: .gray.opacity(0.2), textColor: .primary) {
                        playerData.currentScore = 0
                        dismiss()
                    }
                }
            }
            .padding(35)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 35))
            .padding(.horizontal, 40)
        }
    }

    private func buttonCapsule(_ text: String, color: Color, textColor: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .foregroundColor(textColor)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    GameView(playerName: "")
        .environment(PlayerData())
        .environment(ScoreManager())
}
