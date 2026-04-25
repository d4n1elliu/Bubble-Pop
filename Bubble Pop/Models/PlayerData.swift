//
//  PlayerData.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 26/3/2026.
//

import Foundation
import Observation

@Observable
class PlayerData {
    
    private struct Config {
        static let defaultName: String = ""
        static let defaultScore: Int = 0
    }
    
    var name: String
    var currentScore : Int
    var scoreManager: ScoreManager
    
    init(name: String = Config.defaultName, currentScore: Int = Config.defaultScore, scoreManager: ScoreManager = ScoreManager()) {
        self.name = name
        self.currentScore = currentScore
        self.scoreManager = scoreManager
    }
    
    func resetGame() {
        currentScore = Config.defaultScore
    }
}
