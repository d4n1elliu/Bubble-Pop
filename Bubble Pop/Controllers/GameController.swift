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
    var timer: Timer?
    var player: PlayerData
    var scoreManager: ScoreManager
    weak var scene: GameScene?
    
    var playerScore: Binding<Int>?
    
    let pointsMultiplier = PointsMultiplierManager()
    
    var bubblesSpawned: Int = GameControllerConfig.initialSpawnCount
    let maxBubbles: Int = GameControllerConfig.maxBubbles

    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }

    /// Resets the game state and start countdown timer and initial bubble spawn
    func startGame() {
        /// Confirming all existing timers are cleaned up before starting a new game session
        timer?.invalidate()
        timer = nil
        
        playTime = GameControllerConfig.initialPlayTime
        player.currentScore = GameControllerConfig.initialScore
        bubblesSpawned = GameControllerConfig.initialSpawnCount
        
        pointsMultiplier.resetMultiplier()
        scene?.isPaused = false
        
        /// For populating game screen with bubbles
        for _ in 1...GameControllerConfig.maxBubbles {
            if let gameScene = self.scene {
                BubbleCreation.spawnBubble(in: gameScene)
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: GameControllerConfig.timerInterval, repeats: true) {
            [weak self] _ in
            self?.tick()
        }
    }
    
    /// Handle 1 second interval update for game clock.
    private func tick() {
        if playTime > 0 {
            /// Decreasing play time interval as long as play time is more than 0 seconds
            playTime -= 1
            
            let currentBubbles = scene?.children.filter {
                $0.name == GameControllerConfig.bubbleNodeName
            }.count ?? 0
            if currentBubbles < GameControllerConfig.maxBubbles {
                /// Randomising spawn counts 
                let spawnCount = Int.random(in: 1...3)
                
                for _ in 0..<spawnCount {
                    if let gameScene = self.scene {
                        BubbleCreation.spawnBubble(in: gameScene)
                    }
                }
            }
        } else {
            endGame()
        }
    }
    
    /// Processes a bubble tap, updates the score with multipliers and checks for win conditions.
    func handleTap(points: Int, color: UIColor) {
        let finalPoints = pointsMultiplier.calculatePoints(for: color, basePoints: points)
        player.currentScore += finalPoints
        playerScore?.wrappedValue = player.currentScore
        
        scoreManager.updateHighScore(with: player.currentScore, playerName: player.name)
        
        /// Small delay allows the SpriteKit physics engine to remove nodes before we check the count
        DispatchQueue.main.asyncAfter(deadline: .now() + GameControllerConfig.physicsCleanupDelay) {
            [weak self] in
            guard let self = self else {
                return
            }
            
            let bubbles = self.scene?.children.filter {
                $0.name == GameControllerConfig.bubbleNodeName
            }
            let count = bubbles?.count ?? 0
            if count == 0 {
                self.endGame()
            }
        }
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
