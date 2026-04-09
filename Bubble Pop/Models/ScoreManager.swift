//
//  ScoreManager.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 3/4/2026.
//

import Foundation
import Observation

/// Managing score persistency and using @Observation to automatically update the UI when a new high score is recorded.
@Observable
class ScoreManager {

    private let leaderboard = LeaderboardManager()
    /// Allow leaderboard variable to store the highest value.
    var highScore: Int {
        leaderboard.highestScore
    }
    /// Take results of the game when it is finished and put the scores onto the leaderboards.
    func updateHighScore(with currentScore: Int, playerName: String) {
        /// Passing the score to leaderboard to save it permanently
        leaderboard.addScore(name: playerName, value: currentScore)
    }
    /// Fetching latest score from helper class ScoreManager and trigger an UI refresh when scores list is updated.
    var allScores: [GameScore] {
        leaderboard.scores
    }
}
