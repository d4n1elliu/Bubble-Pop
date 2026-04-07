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

    init(player: PlayerData, scoreManager: ScoreManager) {
        self.player = player
        self.scoreManager = scoreManager
    }

    func startGame() {
        playTime = 60
        player.currentScore = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        if playTime > 0 {
            playTime -= 1
        } else {
            endGame()
        }
    }

    func handleTap(points: Int, color: UIColor) {
        let finalPoints = PointsMultiplierManager().calculatePoints(for: color, basePoints: points)
        player.currentScore += finalPoints
        scoreManager.updateHighScore(with: player.currentScore, playerName: "Player")
    }

    func endGame() {
        timer?.invalidate()
        scene?.isPaused = true
        // Trigger UI overlays via the View
    }
}
