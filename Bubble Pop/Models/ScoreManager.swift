//
//  ScoreManager.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 3/4/2026.
//

import Foundation
import Observation

/// A consistent manager responsible for tracking and saving the user's highest score
/// This class uses @Observable macro to ensure SwiftUI can reactively view and update whenever a new highscore is achieved in the game
@Observable
class ScoreManager {
    private let leaderboard = LeaderboardManager()
    
    /// Current highScore
    var highScore: Int {
        leaderboard.highestScore
    }
    /// Comparing the current high score with any new highScore that saved if it is scored higher
    func updateHighScore(with currentScore: Int, playerName: String) {
        /// Passing the score to leaderboard to save it permanently
        leaderboard.addScore(name: playerName, value: currentScore)
    }
    
    var allScores: [GameScore] {
        leaderboard.scores
    }
}
