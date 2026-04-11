//
//  BubbleConfig.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 10/4/2026.
//

import UIKit
import SpriteKit

enum PhysicsConstants {
    static let bubbleRadius: CGFloat = 30
    static let bubbleName = "Bubbles"
    
    /// Physics Constants
    static let dxThreshold: CGFloat = 0
    static let dyThreshold: CGFloat = 0
    static let perfectBounciness: CGFloat = 1.0
    static let zeroFriction: CGFloat = 0.0
    static let zeroDamping: CGFloat = 0.0
    static let physicsSpeed: CGFloat = 1.0

    /// Motion Constants
    static let maxImpulseRange: CGFloat = 15.0
    static let minImpulseRange: CGFloat = -15.0
}

enum GameControllerConfig{
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

struct BubbleCreation {
    /// Spawns a single bubble with randomized properties and physics into the provided scene.
    static func spawnBubble(in scene: GameScene, avoiding cursorPosition: CGPoint? = nil) {
        /// Determining Bubble Type (Color/Points) based on probability
        let allTypes = BubbleConfig.allCases
        let totalWeight = allTypes.reduce(0) {
            $0 + $1.probability
        }
        let randomNumber = Int.random(in: 1...totalWeight)
        
        var selectedType: BubbleConfig = .red
        var cumulativeWeight = 0
        
        for type in allTypes {
            cumulativeWeight += type.probability
            if randomNumber <= cumulativeWeight {
                selectedType = type
                break
            }
        }
        
        var xPos: CGFloat = 0
        var yPos: CGFloat = 0
        var isValidPosition = false
        var attempts = 0

        // We use 'while !isValidPosition' so the loop runs UNTIL we find a good spot
        while !isValidPosition && attempts < 50 {
            attempts += 1
            
            // FIXED: Ensure xPos uses width and yPos uses height
            xPos = CGFloat.random(in: PhysicsConstants.bubbleRadius...(scene.size.width - PhysicsConstants.bubbleRadius))
            yPos = CGFloat.random(in: PhysicsConstants.bubbleRadius...(scene.size.height - PhysicsConstants.bubbleRadius))
            
            if let cursor = cursorPosition {
                let distance = sqrt(pow(xPos - cursor.x, 2) + pow(yPos - cursor.y, 2))
                // Only accept positions at least 100 points away from cursor
                if distance > 100 {
                    isValidPosition = true
                }
            } else {
                // If no cursor (at game start), any position is immediately valid
                isValidPosition = true
            }
        }
        
        /// Creating visual bubble body
        let bubble = SKShapeNode(circleOfRadius: PhysicsConstants.bubbleRadius)
        bubble.name = PhysicsConstants.bubbleName
        bubble.fillColor = selectedType.color
        bubble.strokeColor = .white
        bubble.lineWidth = 2
        bubble.userData = ["points": selectedType.points, "color": selectedType.color]
        /// Randomize Position (Ensuring it stays within screen bounds)
        bubble.position = CGPoint(x: xPos, y: yPos)
        
        /// Configure Physics Body
        let body = SKPhysicsBody(circleOfRadius: PhysicsConstants.bubbleRadius)
        body.restitution = PhysicsConstants.perfectBounciness
        body.friction = PhysicsConstants.zeroFriction
        body.linearDamping = PhysicsConstants.zeroDamping
        body.allowsRotation = false
        
        bubble.physicsBody = body
        scene.addChild(bubble)
        scene.controller?.bubblesSpawned += 1

        let randomX = CGFloat.random(in: PhysicsConstants.minImpulseRange...PhysicsConstants.maxImpulseRange)
        let randomY = CGFloat.random(in: PhysicsConstants.minImpulseRange...PhysicsConstants.maxImpulseRange)
        
        body.applyImpulse(CGVector(dx: randomX, dy: randomY))
    }
}
