//
//  GameController.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 7/4/2026.
//

import SwiftUI
import SpriteKit

@Observable
class GameController {
    var playTime: Int = 60
    var timer: Timer?
    var player: PlayerData
    var scoreManager: ScoreManager
    weak var scene: GameScene?
    
    var playerScore: Binding<Int>?
    
    private let pointsMultiplier = PointsMultiplierManager()
    
    private var bubblesSpawned: Int = 0
    private let maxBubbles: Int = 15

    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }

    func startGame() {
        
        timer?.invalidate()
        timer = nil
        
        playTime = 60
        player.currentScore = 0
        bubblesSpawned = 0
        
        pointsMultiplier.resetMultiplier()
        
        scene?.isPaused = false
        
        for _ in 1...maxBubbles {
            spawnOneBubble()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func spawnOneBubble() {
        self.scene?.generatingBubbles()
        self.bubblesSpawned += 1
    }

    private func tick() {
        if playTime > 0 {
            playTime -= 1
        } else {
            endGame()
        }
    }

    func handleTap(points: Int, color: UIColor) {
        let finalPoints = pointsMultiplier.calculatePoints(for: color, basePoints: points)
        player.currentScore += finalPoints
        playerScore?.wrappedValue = player.currentScore
        
        scoreManager.updateHighScore(with: player.currentScore, playerName: player.name)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            
            let bubbles = self.scene?.children.filter { $0.name == "Bubbles" }
            let count = bubbles?.count ?? 0
            
            if count == 0 {
                self.endGame()
            }
        }
    }

    func endGame() {
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.scene?.isPaused = true
            self?.scene?.onReturnHome?()
        }
    }
}
