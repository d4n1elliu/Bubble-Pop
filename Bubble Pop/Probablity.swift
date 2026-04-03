//
//  Probablity.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 29/3/2026.
//

import UIKit

enum BubbleColours {
    case red, pink, green, blue, black
    
    /// Bubble color
    var colour: UIColor {
        switch self {
        case .red:
            return .red
        case .pink:
            return .systemPink
        case .green:
            return .systemGreen
        case .blue:
            return .systemBlue
        case .black:
            return .black
        }
    }
    
    /// Points rewarded based on color 
    var points: Int {
        switch self {
        case .pink:
            return 2
        case .green:
            return 5
        case .blue:
            return 8
        case .black:
            return 10
        default:
            return 1
        }
    }
}

func generateBubbleColor() -> BubbleColours {
    /// Probablity chances for bubble spawn
    let randomNumber = Int.random(in: 0..<100)

    switch randomNumber {
    case 0..<40:   /// 0 to 39 (40% chance)
        return .red
    case 40..<70:  /// 40 to 69 (30% chance)
        return .pink
    case 70..<85:  /// 70 to 84 (15% chance)
        return .green
    case 85..<95:  /// 85 to 94 (10% chance)
        return .blue
    default:       /// 95 to 99 (5% chance)
        return .black
    }
}

