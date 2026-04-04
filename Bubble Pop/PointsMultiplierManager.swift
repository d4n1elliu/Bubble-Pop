//
//  PointsMultiplierManager.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 4/4/2026.
//

import Foundation
import SwiftUI
import Combine

class PointsMultiplierManager: ObservableObject {
    @Published var currentMultiplier: Double = 1.0
    private var lastColor: Color?
    
    /// Logic to update score based on bubble color matching
    func calculatePoints(for color: Color, basePoints: Double = 1.0) -> Double {
        if let lastColor = lastColor, lastColor == color {
            // Increase multiplier by 1.5x for same color match
            currentMultiplier *= 1.5
        } else {
            // Reset multiplier if color changes
            currentMultiplier = 1.0
        }
        
        lastColor = color
        return basePoints * currentMultiplier
    }
    
    func resetMultiplier() {
        currentMultiplier = 1.0
        lastColor = nil
    }
}
