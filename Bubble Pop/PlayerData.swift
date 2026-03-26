//
//  PlayerData.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 26/3/2026.
//

import Foundation
import Observation

/// A centralized data model to manage player information across different screens.
/// Using @Observable allows SwiftUI views to update automatically when the name changes.
@Observable
class PlayerData {
    /// Name entered by the player before starting the game.
    var name: String = ""
    
    /// Current score achieved during the game session.
    var currentScore: Int = 0
    
    /// Resets the game state for a new session.
    func resetGame() {
        currentScore = 0
    }
}
