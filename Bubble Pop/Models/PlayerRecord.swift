//
//  PlayerRecord.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 13/4/2026.
//

import Foundation
import SwiftData

@Model
final class PlayerRecord {
    @Attribute(.unique) var name : String
    var highScore: Int
    
    /// - Parameters:
    ///   - name: The player's display name, must be unique across all saved records
    ///   - highScore: The player's best score to save at the time of record creation
    init(name: String, highScore: Int) {
        self.name = name
        self.highScore = highScore
    }
}

