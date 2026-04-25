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
        static let maxEntries: Int = 10
        static let minNameLength: Int = 1
    }
    
    enum LeaderboardError: LocalizedError {
        case encodingFailed(Error)
        case decodingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed(let error):
                return "Failed to save scores. Please try again.\n\nDetails: \(error.localizedDescription)"
            case .decodingFailed(let error):
                return "Failed to load leaderboard data. Please try again.\n\nDetails: \(error.localizedDescription)"
            }
        }
    }
    
    var scores: [GameScore] = [] {
        didSet { saveScores() }
    }
    
    var showAlert: Bool = false
    var alertMessage: String = ""
    
    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
        loadScores()
    }
    
    var highestScore: Int {
        scores.map { $0.score }.max() ?? 0
    }
    
    /// - Parameters:
    ///   - name: The player's name used to identify and match against existing leaderboard entries
    ///   - value: The new score to record, only saved if it exceeds the user's current best score
    func addScore(name: String, value: Int) {
        if let existingIndex = scores.firstIndex(where: {
            $0.playerName.lowercased() == name.lowercased()
        }) {
            if value > scores[existingIndex].score {
                scores[existingIndex] = GameScore(playerName: name, score: value)
            }
        } else {
            scores.append(GameScore(playerName: name, score: value))
        }
        scores.sort { $0.score > $1.score }
        if scores.count > Config.maxEntries {
            scores = Array(scores.prefix(Config.maxEntries))
        }
    }
    
    func clearScores() {
        scores = []
        storage.removeObject(forKey: Config.storageKey)
    }
    
    private func handleError(_ error: LeaderboardError) {
        alertMessage = error.errorDescription ?? "An unexpected error occurred."
        showAlert = true
    }
    
    private func saveScores() {
        do {
            let encoded = try JSONEncoder().encode(scores)
            storage.set(encoded, forKey: Config.storageKey)
        } catch {
            handleError(.encodingFailed(error))
        }
    }

    private func loadScores() {
        guard let data = storage.data(forKey: Config.storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([GameScore].self, from: data)
            scores = decoded.filter {
                $0.playerName.trimmingCharacters(in: .whitespacesAndNewlines).count >= Config.minNameLength
            }
        } catch {
            handleError(.decodingFailed(error))
        }
    }
}
