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
    
    /// Score properties
    var scores: [GameScore] = [] {
        didSet {
            saveScores()
        }
    }
    
    /// Loading the scores
    init() {
        loadScores()
    }
    
    /// Returns the single highest score globally for the HUD.
    var highestScore: Int {
        scores.map { $0.score }.max() ?? 0
    }
    
    
    /// Adds a new score to the list, sorts it and enforces the leaderboard limit.
    func addScore(name: String, value: Int) {
        let newEntry = GameScore(playerName: name, score: value)
        scores.append(newEntry)
        
        /// Sort scores by descending order and have higest score comes first
        scores.sort { $0.score > $1.score }
        
        /// Enforce the limit defined in Config
        if scores.count > Config.maxEntries {
            scores = Array(scores.prefix(Config.maxEntries))
        }
    }
    
    /// Converts the current leaderboard array into a data format and saves it to permanent storage.
    private func saveScores() {
        do {
            /// Transform the array of GameScore objects into JSON data
            let encoded = try JSONEncoder().encode(scores)
            /// Generate encoded data to UserDefaults using our unique configuration key
            UserDefaults.standard.set(encoded, forKey: Config.storageKey)
        } catch {
            // Display an error message if the encoding process fails
            print("Failed to encode leaderboard: \(error.localizedDescription)")
        }
    }
    
    /// Attempts to retrieve and decode previously saved leaderboard data from storage.
    private func loadScores() {
        /// Looking for existing data in UserDefaults; if none exists, exit the function early
        guard let data = UserDefaults.standard.data(forKey: Config.storageKey) else { return }
        
        do {
            /// Transform the stored JSON data back into an array of GameScore objects
            let decoded = try JSONDecoder().decode([GameScore].self, from: data)
            /// Update the local scores array with the retrieved data
            self.scores = decoded
        } catch {
            /// Display an error message if the data is corrupted or cannot be read
            print("Failed to decode leaderboard: \(error.localizedDescription)")
        }
    }
}
