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
        static let minScore: Int = 0
    }
    
    enum ScoreManagerError : LocalizedError {
        case emptyPlayerName
        case tooLongPlayerName(Int)
        case negativeScore(Int)
        
        var errorDescription: String? {
            switch self {
            case .emptyPlayerName:
                return "Player name cannot be empty."
            case .tooLongPlayerName(let length):
                return "Player name cannot exceed \(Config.maxNameLength) characters. Received: \(length)."
            case .negativeScore(let score):
                return "Score cannot be a negative value. Received: \(score)."
            }
        }
    }
    
    private let leaderboard: LeaderboardManager
    
    init(leaderboard: LeaderboardManager = LeaderboardManager()) {
        self.leaderboard = leaderboard
    }

    var highScore: Int {
        leaderboard.highestScore
    }
    
    var allScores: [GameScore] {
        leaderboard.scores
    }
    
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    
    /// - Parameters:
    ///   - currentScore: The player's final score from the completed game session to be recorded on the leaderboard
    ///   - playerName: The player's display name used to identify and store the score entry
    func updateHighScore(with currentScore: Int, playerName: String) {
        let trimmedName = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count >= Config.minNameLength else {
            triggerAlert(for: .emptyPlayerName)
            return
        }
        guard trimmedName.count <= Config.maxNameLength else {
            triggerAlert(for: .tooLongPlayerName(trimmedName.count))
            return
        }
        guard currentScore >= Config.minScore else {
            triggerAlert(for: .negativeScore(currentScore))
            return
        }
        leaderboard.addScore(name: trimmedName, value: currentScore)
    }
    
    private func triggerAlert(for error: ScoreManagerError) {
        alertMessage = error.errorDescription ?? "An unexpected error occurred."
        showAlert = true
    }
    
    func resetLeaderboard() {
        leaderboard.clearScores()
    }
}
