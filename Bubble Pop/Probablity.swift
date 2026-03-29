//
//  Probablity.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 29/3/2026.
//

import UIKit

enum BubbleColours {
    case red, pink, green, blue, black
    
    var colour: UIColor {
        switch self {
        case .red: return .red
        case .pink: return .systemPink
        case .green: return .systemGreen
        case .blue: return .systemBlue
        case .black: return .black
        }
    }
}

func generateBubbleColor() -> UIColor {
    
    // Probablity chances for bubble spawn
    let randomNumber = Int.random(in: 0..<100)
    
    switch randomNumber {
    case 0..<40:   // 0 to 39 (40% chance)
        return BubbleColours.red.colour
    case 40..<70:  // 40 to 69 (30% chance)
        return BubbleColours.pink.colour
    case 70..<85:  // 70 to 84 (15% chance)
        return BubbleColours.green.colour
    case 85..<95:  // 85 to 94 (10% chance)
        return BubbleColours.blue.colour
    default:       // 95 to 99 (5% chance)
        return BubbleColours.black.colour
    }
}

