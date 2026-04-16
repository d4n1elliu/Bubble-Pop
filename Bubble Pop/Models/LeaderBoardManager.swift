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
        if let index = scores.firstIndex(where: { $0.playerName.lowercased() == name.lowercased() }) {

            if value > scores[index].score {
                scores[index] = GameScore(playerName: name, score: value)
            }
        } else {
            let newEntry = GameScore(playerName: name, score: value)
            scores.append(newEntry)
        }
        
        scores.sort { $0.score > $1.score }
        
        if scores.count > Config.maxEntries {
            scores = Array(scores.prefix(Config.maxEntries))
        }
    }
    
    func clearScores() {
        self.scores = []
        
        UserDefaults.standard.removeObject(forKey: Config.storageKey)
        print("Leaderboard successfully cleared.")
    }
    
    /// Converts the current leaderboard array into a data format and saves it to permanent storage.
    private func saveScores() {
        do {
            /// Transform the array of GameScore objects into JSON data
            let encoded = try JSONEncoder().encode(scores)
            /// Generate encoded data to UserDefaults using our unique configuration key
            UserDefaults.standard.set(encoded, forKey: Config.storageKey)
        } catch {
            /// Display an error message if the encoding process fails
            print("Failed to encode leaderboard: \(error.localizedDescription)")
        }
    }
    
    /// Attempts to retrieve and decode previously saved leaderboard data from storage.
    private func loadScores() {
        /// Looking for existing data in UserDefaults; if none exists, exit the function early
        guard let data = UserDefaults.standard.data(forKey: Config.storageKey) else {
            return
        }
        
        do {
            /// Transform the stored JSON data back into an array of GameScore objects
            let decoded = try JSONDecoder().decode([GameScore].self, from: data)
            /// Update the local scores array with the retrieved data
            self.scores = decoded.filter {
                !$0.playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
        } catch {
            /// Display an error message if the data is corrupted or cannot be read
            print("Failed to decode leaderboard: \(error.localizedDescription)")
        }
    }
}
