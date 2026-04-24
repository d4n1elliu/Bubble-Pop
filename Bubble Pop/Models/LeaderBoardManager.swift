//
//  LeaderBoardManager.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 6/4/2026.
//

import Foundation

struct GameScore: Identifiable, Codable {
    var id = UUID()
    let playerName: String
    let score: Int
}

@Observable

class LeaderboardManager {

    private struct Config {
        static let storageKey = "leaderboard_data"
        static let maxEntries = 10
    }
    
    var scores: [GameScore] = [] {
        didSet {
            saveScores()
        }
    }
    
    var failedMessage: Bool = false
    var alertMessage: String = ""

    init() {
        loadScores()
    }
    
    var highestScore: Int {
        scores.map { $0.score }.max() ?? 0
    }
    
    // Adds a new score to the list, sorts it and enforces the leaderboard limit.
    func addScore(name: String, value: Int) {
        if let index = scores.firstIndex(where: {
            $0.playerName.lowercased() == name.lowercased()
        }) {
            if value > scores[index].score {
                scores[index] = GameScore(playerName: name, score: value)
            }
        } else {
            let newEntry = GameScore(playerName: name, score: value)
            scores.append(newEntry)
        }
        scores.sort {
            $0.score > $1.score
        }
        if scores.count > Config.maxEntries {
            scores = Array(scores.prefix(Config.maxEntries))
        }
    }
    
    func clearScores() {
        scores = []
        UserDefaults.standard.removeObject(forKey: Config.storageKey)
    }
    
    // Converts the current leaderboard array into a data format and saves it to permanent storage.
    private func saveScores() {
        do {
            let encoded = try JSONEncoder().encode(scores)
            UserDefaults.standard.set(encoded, forKey: Config.storageKey)
        } catch {
            alertMessage = "Failed to save scores. Please try again.\n\nDetails: \(error.localizedDescription)"
            failedMessage = true
        }
    }
    
    // Attempts to retrieve and decode previously saved leaderboard data from storage.
    private func loadScores() {
        guard let data = UserDefaults.standard.data(forKey: Config.storageKey) else {
            return
        }
        do {
            let decoded = try JSONDecoder().decode([GameScore].self, from: data)
            scores = decoded.filter {
                !$0.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        } catch {
            alertMessage = "Failed to load leaderboard data. Please try again. \n\nDetails: \(error.localizedDescription)"
            failedMessage = true
        }
    }
}
