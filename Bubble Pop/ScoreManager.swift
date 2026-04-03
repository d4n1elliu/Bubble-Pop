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
    
    /// A unique identifier or saving data to UserDefaults
    private let highScoreKey: String
    
    /// Current highScore
    /// This value synched with local storage
    var highScore: Int = 0
    
    /// Initializes a new ScoreManager instance.
    
    init(key: String = "bubble_pop_highscore") {
        self.highScoreKey = key
        // Retrieve the previously saved score from the device's standard storage.
        self.highScore = UserDefaults.standard.integer(forKey: highScoreKey)
    }
    
    // Comparing the current high score with any new highScore that saved if it is scored higher
    func updateHighScore(with currentScore: Int) {
        
        // Only update score if the new score exceeds the existing record.
        if currentScore > highScore {
            highScore = currentScore
            UserDefaults.standard.set(highScore, forKey: highScoreKey)
        }
    }
}
