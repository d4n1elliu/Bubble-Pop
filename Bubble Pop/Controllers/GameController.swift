//
//  GameController.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 7/4/2026.
//

import SwiftUI
import SpriteKit

/// Managing core logic, timer and score state for the BubblePop session
@Observable
class GameController {
    
    var playTime: Int = GameControllerConfig.initialPlayTime
    
    var gameTimeframe: Int = GameControllerConfig.initialPlayTime {
        didSet { playTime = gameTimeframe }
    }
    var maxBubbles: Int = GameControllerConfig.maxBubbles
    
    var timer: Timer?
    var player: PlayerData
    var scoreManager: ScoreManager
    var lastTapLocation: CGPoint?
    weak var scene: GameScene?
    private var lastTapColor: UIColor?
    
    var playerScore: Binding<Int>?
    
    let pointsMultiplier = PointsMultiplierManager()
    
    var bubblesSpawned: Int = GameControllerConfig.initialSpawnCount
    private var bubbleRefreshInterval: Int = 0
    
    func configure(time: Int, maxBubbles: Int, scene: GameScene) {
        self.gameTimeframe = time
        self.playTime = time
        self.maxBubbles = maxBubbles
        self.scene = scene
        scene.controller = self
    }
    
    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }
    
    /// Resets the game state and start countdown timer and initial bubble spawn
    func startGame() {
        /// Confirming all existing timers are cleaned up before starting a new game session
        timer?.invalidate()
        timer = nil
        
        bubbleRefreshInterval = 0
        lastTapLocation = nil
        lastTapColor = nil
        
        scene?.removeAllChildren()
        
        playTime = gameTimeframe
        player.currentScore = GameControllerConfig.initialScore
        
        self.bubblesSpawned = GameControllerConfig.maxBubbles
        pointsMultiplier.resetMultiplier()
        scene?.isPaused = false
        
        /// Use a small delay to ensure the scene frame is correctly set before spawning
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            [weak self] in
            guard let self = self, let gameScene = self.scene else {
                return
            }
            for _ in 0..<self.bubblesSpawned {
                BubbleCreation.spawnBubble(in: gameScene, avoiding: nil)
            }
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: GameControllerConfig.timerInterval, repeats: true) {
            [weak self] _ in
            self?.tick()
        }
    }
    
    /// Handle 1 second interval update for game clock.
    private func tick() {
        guard playTime > 0 else {
            endGame()
            return
        }
        playTime -= 1
        
        bubbleRefreshInterval += 1
        /// Decreasing play time interval as long as play time is more than 0 seconds
        if bubbleRefreshInterval >= 2 {
            if let gameScene = self.scene {
                let currentBubbles = gameScene.children.filter {
                    $0.name == GameControllerConfig.bubbleNodeName
                }
                
                if !currentBubbles.isEmpty {
                    // Randomly decide how many to remove (e.g., between 1 and 3)
                    let removalCount = Int.random(in: 1...min(currentBubbles.count, 3))
                    let bubblesToRemove = currentBubbles.shuffled().prefix(removalCount)
                    
                    for bubble in bubblesToRemove {
                        bubble.removeFromParent()
                    }
                }
                
                /// Refresh/Replace with a random number of new bubbles
                /// This ensures the count varies slightly every second as per requirement 9
                let remainingCount = gameScene.children.filter {
                    $0.name == GameControllerConfig.bubbleNodeName
                }.count
                let maxToSpawn = GameControllerConfig.maxBubbles - remainingCount
                
                if maxToSpawn > 0 {
                    let spawnCount = Int.random(in: 1...maxToSpawn)
                    for _ in 0..<spawnCount {
                        BubbleCreation.spawnBubble(in: gameScene, avoiding: lastTapLocation)
                    }
                }
            }
            bubbleRefreshInterval = 0
        }
    }
    
    /// Processes a bubble tap, updates the score with multipliers and checks for win conditions.
    func handleTap(at location: CGPoint, points: Int, color: UIColor) {
        self.lastTapLocation = location
        
        var finalPoints = Double(points)
        if let lastColor = lastTapColor, lastColor == color {
            finalPoints = (finalPoints * 1.5).rounded()
        }
        
        lastTapColor = color
        player.currentScore += Int(finalPoints)
        playerScore?.wrappedValue = player.currentScore
        scoreManager.updateHighScore(with: player.currentScore, playerName: player.name)
    }
    
    /// Stops the timer and triggers the navigation back to the home/result screen.
    func endGame() {
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            /// Pause the physics world immediately
            self.scene?.isPaused = true
            
            /// Final High Score check before the overlay appears
            /// Using player.name from your PlayerData model
            self.scoreManager.updateHighScore(
                with: self.player.currentScore,
                playerName: self.scene?.playerName ?? "Unknown"
            )
            
            /// Triggers the overlay in GameView
            self.scene?.onReturnHome?()
        }
    }
}
