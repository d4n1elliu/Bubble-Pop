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
    private var lastColor: UIColor?
    
    /// Logic to update score based on bubble color matching
    func calculatePoints(for color: UIColor, basePoints: Int) -> Int {
        var multiplier: Double = 1.0
        
        /// Convert current UIColor to a SwiftUI Color or compare UIColors directly
        if let last = lastColor, last == color {
            multiplier = 1.5
        }
        
        lastColor = color
        let finalValue = Double(basePoints) * multiplier
        return Int(finalValue.rounded())
    }
    
    func resetMultiplier() {
        currentMultiplier = 1.0
        lastColor = nil
    }
}
