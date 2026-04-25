//
//  ScoreManager.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 3/4/2026.
//

import Foundation
import Observation

@Observable
class ScoreManager {
    
    private struct Config {
        static let maxNameLength: Int = 15
        static let minNameLength: Int = 1
    }
    
    enum ScoreManagerError : LocalizedError {
        case emptyName
        case longName
        case negativeScore
        
        var errorDescription: String? {
            switch self {
            case .emptyName: 
                return "Player name cannot be empty."
            case .longName:
                return "Player name cannot exceed \(Config.maxNameLength) characters."
            case .negativeScore:
                return "Score cannot be a negative value."
            }
        }
    }
    
    private let leaderboard = LeaderboardManager()

    var highScore: Int {
        leaderboard.highestScore
    }
    
    var allScores: [GameScore] {
        leaderboard.scores
    }
    
    /// - Parameters:
    ///   - currentScore: The player's final score from the completed game session to be recorded on the leaderboard
    ///   - playerName: The player's display name used to identify and store the score entry
    func updateHighScore(with currentScore: Int, playerName: String) throws {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count >= Config.minNameLength else { throw ScoreManagerError.emptyName }
        guard trimmedName.count <= Config.maxNameLength else { throw ScoreManagerError.longName }
        guard currentScore >= 0 else { throw ScoreManagerError.negativeScore }
        leaderboard.addScore(name: trimmedName, value: currentScore)
    }
    
    func resetLeaderboard() {
        leaderboard.clearScores()
    }
}
