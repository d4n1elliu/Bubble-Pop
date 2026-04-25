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
        static let minMultiplier : Double = 1.0
        static let maxMultiplier : Double = 1.5
    }
    
    enum PointsMultiplierError: LocalizedError {
        case negativeBasePoints(Int)
        case invalidMultiplier(Double)

        var errorDescription: String? {
            switch self {
            case .negativeBasePoints(let points):
                return "Base points cannot be negative. Received: \(points)."
            case .invalidMultiplier(let multiplier):
                return "Multiplier \(multiplier) is outside the valid range of \(Config.minMultiplier)x–\(Config.maxMultiplier)x."
            }
        }
    }
    
    @Published private(set) var currentMultiplier: Double = Config.defaultMultiplier
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    private var lastPoppedColor: UIColor?
    
    /// - Parameters:
    ///   - color: The popped bubble's color, if it matches the last popped bubble a 1.5x combo bonus is applied
    ///   - basePoints: The bubble's raw point value before the combo multiplier is applied
    func calculatePoints(for color: UIColor, basePoints: Int) -> Int? {
        guard basePoints >= Config.minBasePoints else {
            triggerAlert(for: .negativeBasePoints(basePoints))
            return nil
        }
        let multiplier = lastPoppedColor == color ? Config.comboMultiplier : Config.defaultMultiplier
        guard multiplier >= Config.minMultiplier && multiplier <= Config.maxMultiplier else {
            triggerAlert(for: .invalidMultiplier(multiplier))
            return nil
        }
        currentMultiplier = multiplier
        lastPoppedColor = color
        return Int((Double(basePoints) * currentMultiplier).rounded())
    }
    
    private func triggerAlert(for error: PointsMultiplierError) {
            alertMessage = error.errorDescription ?? "An unexpected error occurred."
            showAlert = true
        }
    
    func resetMultiplier() {
        currentMultiplier = Config.defaultMultiplier
        lastPoppedColor = nil
    }
}
