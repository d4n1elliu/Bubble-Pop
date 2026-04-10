//
//  BubbleConfig.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 10/4/2026.
//

import UIKit

enum BubbleConfig: CaseIterable {
    case red, pink, green, blue, black
    
    var points: Int {
        switch self {
            case .red:   return 1
            case .pink:  return 2
            case .green: return 5
            case .blue:  return 8
            case .black: return 10
        }
    }
    var probability: Int {
        switch self {
            case .red:   return 40
            case .pink:  return 30
            case .green: return 15
            case .blue:  return 10
            case .black: return 5
        }
    }
    var color: UIColor {
        switch self {
            case .red:   return .red
            case .pink:  return .systemPink
            case .green: return .green
            case .blue:  return .systemBlue
            case .black: return .black
        }
    }
}

struct PhysicsConstants {
    static let bubbleRadius: CGFloat = 30
    static let bubbleName = "Bubbles"
    
    /// Physics Constants
    static let dxThreshold: CGFloat = 0
    static let dyThreshold: CGFloat = 0
    static let perfectBounciness: CGFloat = 1.0
    static let zeroFriction: CGFloat = 0.0
    static let zeroDamping: CGFloat = 0.0
    static let physicsWorldSpeed: CGFloat = 1.0
    
    /// Motion Constants
    static let maxImpulseRange: CGFloat = 15.0
    static let minImpulseRange: CGFloat = -15.0
}

struct GameControllerConfig{
    static let initialPlayTime: Int = 60
    static let maxBubbles: Int = 15
    static let timerInterval: TimeInterval = 1.0
    static let initialScore: Int = 0
    static let initialSpawnCount: Int = 0

    /// Delay for SpriteKit node removal before performing logic checks
    static let physicsCleanupDelay: Double = 0.15

    /// Target node name for filtering game entities
    static let bubbleNodeName = "Bubbles"
}
