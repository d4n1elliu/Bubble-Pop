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
    
    private struct Config {
        static let defaultMultiplier: Double = 1.0
        static let comboMultiplier: Double = 1.5
        static let minBasePoints: Int = 0
    }
    
    enum PointsMultiplierError: LocalizedError {
        case negativeBasePoints
        
        var errorDescription: String? {
            switch self {
            case .negativeBasePoints:
                return "Base points cannot be a negative value."
            }
        }
    }
    
    @Published var currentMultiplier: Double = Config.defaultMultiplier
    private var lastColor: UIColor?
    
    /// - Parameters:
    ///   - color: The color of the popped bubble, a combo multiplier is applied if it matches the previous bubble's color
    ///   - basePoints: The bubble's point value before any combo multiplier is applied
    func calculatePoints(for color: UIColor, basePoints: Int) throws -> Int {
        guard basePoints >= Config.minBasePoints else { throw PointsMultiplierError.negativeBasePoints }
        currentMultiplier = lastColor == color ? Config.comboMultiplier : Config.defaultMultiplier
        lastColor = color
        return Int((Double(basePoints) * currentMultiplier).rounded())
    }
    
    func resetMultiplier() {
        currentMultiplier = Config.defaultMultiplier
        lastColor = nil
    }
}
