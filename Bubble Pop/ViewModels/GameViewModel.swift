//
//  GameViewModel.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 17/4/2026.
//

import SwiftUI
import SpriteKit

/// ViewModel managing core game logic, timer, and score state for the BubblePop session.
/// Sits between the Model layer (PlayerData, ScoreManager) and the View layer (GameScene, GameView).
@Observable
class GameViewModel {

    var playTime: Int = GameControllerConfig.initialPlayTime
    var gameTimeframe: Int = GameControllerConfig.initialPlayTime {
        didSet { playTime = gameTimeframe }
    }
    var maxBubbles: Int = GameControllerConfig.maxBubbles
    var bubblesSpawned: Int = GameControllerConfig.initialSpawnCount

    var player: PlayerData
    var scoreManager: ScoreManager
    let pointsMultiplier = PointsMultiplierManager()

    weak var scene: GameScene?

    private var timer: Timer?
    private var lastTapLocation: CGPoint?
    private var lastTapColor: UIColor?
    private var bubbleRefreshInterval: Int = 0

    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }

    func configure(time: Int, maxBubbles: Int, scene: GameScene) {
        self.gameTimeframe = time
        self.playTime = time
        self.maxBubbles = maxBubbles
        self.scene = scene
        scene.controller = self
    }

    /// Resets game state and starts the countdown timer and initial bubble spawn.
    func startGame() {
        timer?.invalidate()
        timer = nil
        bubbleRefreshInterval = 0
        lastTapLocation = nil
        lastTapColor = nil
        scene?.removeAllChildren()
        playTime = gameTimeframe
        player.currentScore = GameControllerConfig.initialScore
        bubblesSpawned = GameControllerConfig.maxBubbles
        pointsMultiplier.resetMultiplier()
        scene?.isPaused = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self, let scene = self.scene else {
                return
            }
            for _ in 0..<self.bubblesSpawned {
                self.spawnBubbleWithFadeIn(in: scene)
            }
        }

        timer = Timer.scheduledTimer(withTimeInterval: GameControllerConfig.timerInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    /// Stops the timer and triggers navigation back to the home/result screen.
    func endGame() {
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.scene?.isPaused = true
            self.scoreManager.updateHighScore(
                with: self.player.currentScore,
                playerName: self.scene?.playerName ?? "Unknown"
            )
            self.scene?.onReturnHome?()
        }
    }

    /// Processes a bubble tap, applies multipliers, and updates the score.
    func handleTap(at location: CGPoint, points: Int, color: UIColor) {
        lastTapLocation = location
        var finalPoints = Double(points)
        
        if let lastColor = lastTapColor, lastColor == color {
            finalPoints = (finalPoints * 1.5).rounded()
        }

        lastTapColor = color
        player.currentScore += Int(finalPoints)
        scoreManager.updateHighScore(with: player.currentScore, playerName: player.name)
    }

    /// Handles each 1-second tick: decrements the clock and refreshes bubbles.
    private func tick() {
        guard playTime > 0 else {
            endGame()
            return
        }
        playTime -= 1

        guard let scene else {
            return
        }
        /// Fade out a random selection for existing bubbles
        let currentBubbles = scene.children.filter { $0.name == GameControllerConfig.bubbleNodeName }
        if !currentBubbles.isEmpty {
            let removalCount = Int.random(in: 1...min(currentBubbles.count, 3))
            currentBubbles.shuffled().prefix(removalCount).forEach { $0.removeFromParent() }
        }

        let remaining = scene.children.filter { $0.name == GameControllerConfig.bubbleNodeName }.count
        let maxToSpawn = GameControllerConfig.maxBubbles - remaining
        guard maxToSpawn > 0 else { return }

        let spawnCount = Int.random(in: 1...maxToSpawn)
        for _ in 0..<spawnCount {
            BubbleCreation.spawnBubble(in: scene, avoiding: lastTapLocation)
        }
    }
    /// Spawns a bubble into the scene and fades it in smoothly.
    private func spawnBubbleWithFadeIn(in scene: GameScene) {
        let bubble = BubbleCreation.spawnBubble(in: scene, avoiding: lastTapLocation)
        bubble.alpha = 0
        bubble.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    /// Fades a bubble out smoothly then removes it from the scene.
    private func fadeBubbleOut(_ bubble: SKNode) {
        bubble.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))
    }
}


