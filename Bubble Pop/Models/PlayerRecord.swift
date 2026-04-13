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
    init(name: String, highScore: Int) {
        self.name = name
        self.highScore = highScore
    }
}

