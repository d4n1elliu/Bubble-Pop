//
//  GameViewModel.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 17/4/2026.
//

import SwiftUI
import SpriteKit

@Observable
class GameViewModel {
    
    var remainingPlayTime: Int = GameControllerConfig.initialPlayTime
    var totalGameDuration: Int = GameControllerConfig.initialPlayTime { didSet { remainingPlayTime = totalGameDuration } }
    var maxBubbleCount: Int = GameControllerConfig.maxBubbles
    var currentSpawnCount: Int = GameControllerConfig.initialSpawnCount
    var player: PlayerData
    var scoreManager: ScoreManager
    let pointsMultiplier = PointsMultiplierManager()
    
    weak var scene: GameScene?
    private var gameTimer: Timer?
    private var lastTappedLocation: CGPoint?
    private var lastTappedBubbleColor: UIColor?
    
    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }
    
    /// - Parameters:
    ///   - time: Game duration in seconds
    ///   - maxBubbles: Max bubbles that can appear on screen at once
    ///   - scene: GameScene to attach the controller to
    func configure(time: Int, maxBubbles: Int, scene: GameScene) {
        self.totalGameDuration = time
        self.remainingPlayTime = time
        self.maxBubbleCount = maxBubbles
        self.scene = scene
        scene.controller = self
    }
    
    func startGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        lastTappedLocation = nil
        lastTappedBubbleColor = nil
        scene?.removeAllChildren()
        remainingPlayTime = totalGameDuration
        player.currentScore = GameControllerConfig.initialScore
        currentSpawnCount = GameControllerConfig.maxBubbles
        pointsMultiplier.resetMultiplier()
        scene?.isPaused = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + GameControllerConfig.initialSpawnDelay) { [weak self] in
            guard let self, let scene = self.scene else {
                return
            }
            for _ in 0..<self.currentSpawnCount {
                self.spawnBubbleWithFadeIn(in: scene)
            }
        }
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: GameControllerConfig.timerInterval, repeats: true) { [weak self] _ in
            self?.gameTick()
        }
    }
    
    func endGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.scene?.isPaused = true
            self.scoreManager.updateHighScore(
                with: self.player.currentScore,
                playerName: self.scene?.playerName ?? GameControllerConfig.unknownPlayerName
            )
            self.scene?.onReturnHome?()
        }
    }
    /// - Parameters:
    ///   - location: The screen coordinate of the tapped bubble
    ///   - points: The bubble's point value before any combo bonus is applied
    ///   - color: The tapped bubble's color, triggers a 1.5x bonus if it matches the previous bubble
    func handleTap(at tappedLocation: CGPoint, points bubblePoints: Int, color bubbleColor: UIColor) {
        lastTappedLocation = tappedLocation
        let finalScore = pointsMultiplier.calculatePoints(for: bubbleColor, basePoints: bubblePoints) ?? bubblePoints
        player.currentScore += finalScore
        scoreManager.updateHighScore(with: player.currentScore, playerName: player.name)
    }
    
    private func gameTick() {
        guard remainingPlayTime > GameControllerConfig.gameOverThreshold else {
            endGame()
            return
        }
        remainingPlayTime -= 1
        
        guard let scene else {
            return
        }
        let activeBubbles = scene.children.filter { $0.name == GameControllerConfig.bubbleNodeName }
        if !activeBubbles.isEmpty {
            let bubblesToRemove = Int.random(in: GameControllerConfig.minBubbleRemoval...min(activeBubbles.count, GameControllerConfig.maxBubbleRemoval))
            activeBubbles.shuffled().prefix(bubblesToRemove).forEach { $0.removeFromParent() }
        }
        
        let remainingBubbleCount = scene.children.filter { $0.name == GameControllerConfig.bubbleNodeName }.count
        let availableBubbleSlots = GameControllerConfig.maxBubbles - remainingBubbleCount
        guard availableBubbleSlots > GameControllerConfig.gameOverThreshold else { return }
        
        let bubblesToSpawn = Int.random(in: GameControllerConfig.minBubbleRemoval...availableBubbleSlots)
        for _ in 0..<bubblesToSpawn {
            BubbleCreation.spawnBubble(in: scene, avoiding: lastTappedLocation)
        }
    }
    private func spawnBubbleWithFadeIn(in scene: GameScene) {
        let bubble = BubbleCreation.spawnBubble(in: scene, avoiding: lastTappedLocation)
        bubble.alpha = GameControllerConfig.bubbleInitialAlpha
        bubble.run(SKAction.fadeIn(withDuration: GameControllerConfig.bubbleFadeInDuration))
    }
    
    private func fadeBubbleOut(_ bubble: SKNode) {
        bubble.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: GameControllerConfig.bubbleFadeOutDuration),
            SKAction.removeFromParent()
        ]))
    }
}
