//
//  GameView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 8/4/2026.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    let playerName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData
    @Environment(ScoreManager.self) private var scoreManager
    
    @State private var showReturnButton = false
    @State private var showScoreBoard = false
    @State private var viewModel: GameViewModel?
    @State private var isCountingDown = true
    @State private var countdownValue: Int = GameViewUI.initialCountdownValue
    
    @AppStorage("gameTimeframe") private var timeframe = GameControllerConfig.initialPlayTime
    @AppStorage("maxBubbles") private var maximumBubbles = GameControllerConfig.maxBubbles
    
    @State private var gameScene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        return scene
    }()
    
    var body: some View {
        VStack(spacing: GameViewUI.rootVStackSpacing) {
            HStack {
                statColumn(title: "Time Left", value: "\(viewModel?.remainingPlayTime ?? timeframe)", color: (viewModel?.remainingPlayTime ?? timeframe) <= GameViewUI.timeWarningThreshold ? .red : .primary)
                    .frame(maxWidth: .infinity)
                statColumn(title: "Score", value: "\(playerData.currentScore)")
                    .frame(maxWidth: .infinity)
                statColumn(title: "High Score", value: "\(scoreManager.highScore)")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            GeometryReader { geo in
                ZStack {
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: GameViewUI.gradientStopOne, location: GameViewUI.gradientLocationOne),
                            Gradient.Stop(color: GameViewUI.gradientStopTwo, location: GameViewUI.gradientLocationTwo),
                            Gradient.Stop(color: GameViewUI.gradientStopThree, location: GameViewUI.gradientLocationThree),
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
                        .id(countdownValue)
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
    /// - Parameters:
    ///   - title: The label displayed above the value
    ///   - value: The current stat value to display
    ///   - color: The colour applied to the value text
    private func statColumn(title: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: GameViewUI.statColumnSpacing) {
            Text(title).font(.system(size: GameViewUI.hudFontSize, weight: .semibold))
            Text(value).font(.system(size: GameViewUI.hudValueFontSize, weight: .medium, design: .monospaced)).foregroundColor(color)
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
            Color.black.opacity(GameViewUI.overlayOpacity).ignoresSafeArea().transition(.opacity)
            
            VStack(spacing: GameViewUI.overlaySpacing) {
                VStack(spacing: GameViewUI.overlayInnerSpacing) {
                    Text(viewModel?.remainingPlayTime ?? GameViewUI.defaultRemainingTime <= GameViewUI.defaultRemainingTime ? "TIME'S UP!" : "GAME OVER")
                        .font(.system(size: GameViewUI.gameOverFontSize, weight: .black, design: .rounded))
                    Text(playerName.uppercased())
                        .font(.headline).foregroundColor(.secondary)
                }
                
                VStack(spacing: GameViewUI.scoreSpacing) {
                    Text("FINAL SCORE").font(.caption).bold().tracking(GameViewUI.trackingSpacing)
                    Text("\(playerData.currentScore)").font(.system(size: GameViewUI.scoreFontSize, weight: .black, design: .rounded))
                }
                
                VStack(spacing: GameViewUI.buttonSpacing) {
                    buttonCapsule("Restart Game", color: .blue) {
                        playerData.currentScore = GameViewUI.resetScore
                        showReturnButton = false
                        countdownValue += GameViewUI.countdownIncrement
                        isCountingDown = true
                        gameScene.prepareToRestartSession()
                    }
                    buttonCapsule("Scoreboard", color: .orange) {
                        showScoreBoard = true
                    }
                    buttonCapsule("Main Menu", color: .gray.opacity(GameViewUI.mainMenuOpacity), textColor: .primary) {
                        playerData.currentScore = GameViewUI.initialCurrentScore
                        dismiss()
                    }
                }
            }
            .padding(GameViewUI.overlayPadding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: GameViewUI.overlayCornerRadius))
            .padding(.horizontal, GameViewUI.overlayHorizontalPadding)
        }
    }
    /// - Parameters:
    ///   - text: The button label text
    ///   - color: The background colour of the button
    ///   - textColor: The foreground colour of the button label
    ///   - action: The closure to execute when the button is tapped
    private func buttonCapsule(_ text: String, color: Color, textColor: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, GameViewUI.buttonPadding)
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
