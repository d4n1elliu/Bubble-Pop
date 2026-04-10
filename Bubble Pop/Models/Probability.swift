//
//  Probablity.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 29/3/2026.
//

import UIKit

struct BubbleProbability {
    
    /// Points for different bubble colour
    private enum Points {
        static let red = 1
        static let pink = 2
        static let green = 5
        static let blue = 8
        static let black = 10
    }
    
    /// Bubbles probability percentage
    private enum ProbabilityPercentage {
        static let red = 40
        static let pink = 30
        static let green = 15
        static let blue = 10
        static let black = 5
    }
    
    /// Bubble properties
    let colour: UIColor
    let points: Int
    let probabilityForAppearance: Int
    
    /// Static data type for bubble properties
    static let allTypes: [BubbleProbability] = [
        BubbleProbability(colour: .red,
                          points: Points.red,
                          probabilityForAppearance: ProbabilityPercentage.red),
        BubbleProbability(colour: .systemPink,
                          points: Points.pink,
                          probabilityForAppearance: ProbabilityPercentage.pink),
        BubbleProbability(colour: .green,
                          points: Points.green,
                          probabilityForAppearance: ProbabilityPercentage.green),
        BubbleProbability(colour: .systemBlue,
                          points: Points.blue,
                          probabilityForAppearance: ProbabilityPercentage.blue),
        BubbleProbability(colour: .black,
                          points: Points.black,
                          probabilityForAppearance: ProbabilityPercentage.black)
    ]
    
    static func generateBubbleColor() -> BubbleProbability {
        /// Calculate the total probability up to 100%
        let probabilityCheck = allTypes.reduce(0) {
            $0 + $1.probabilityForAppearance
        }
        
        /// Roll the dice
        let randomNumber = Int.random(in: 1...probabilityCheck)
        
        /// Find which "bracket" the random number falls into
        var cumulativeWeight = 0
        for bubbleType in allTypes {
            cumulativeWeight += bubbleType.probabilityForAppearance
            if randomNumber <= cumulativeWeight {
                return bubbleType
            }
        }
        /// Fallback
        return allTypes[0]
    }
}

