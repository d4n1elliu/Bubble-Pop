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
    var lastTapLocation: CGPoint?
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
        lastTapLocation = nil
        
        scene?.removeAllChildren()
        
        playTime = GameControllerConfig.initialPlayTime
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
        if playTime > 0 {
            /// Decreasing play time interval as long as play time is more than 0 seconds
            playTime -= 1
            
            let currentBubbles = scene?.children.filter {
                $0.name == GameControllerConfig.bubbleNodeName
            }.count ?? 0
            if currentBubbles < GameControllerConfig.maxBubbles {
                let needed = GameControllerConfig.maxBubbles - currentBubbles
                /// Spawn up to 5 at a time to refill the screen faster
                let spawnLimit = min(needed, 5)
                
                for _ in 0..<spawnLimit {
                    if let gameScene = self.scene {
                        BubbleCreation.spawnBubble(in: gameScene, avoiding: lastTapLocation)
                    }
                }
            }
        } else {
            endGame()
        }
    }
    
    /// Processes a bubble tap, updates the score with multipliers and checks for win conditions.
    func handleTap(at location: CGPoint, points: Int, color: UIColor) {
        self.lastTapLocation = location
        
        let finalPoints = pointsMultiplier.calculatePoints(for: color, basePoints: points)
        player.currentScore += finalPoints
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
