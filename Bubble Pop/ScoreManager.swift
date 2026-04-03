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
    var highScore: Int = 0
    init(highScore: Int) {
        self.highScore = highScore
    }
    
    func updateHighScore(with score: Int) {
        highScore = max(highScore, score)
    }
}
