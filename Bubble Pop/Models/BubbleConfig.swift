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
    static let perfectBounciness: CGFloat = 1.0
    static let zeroFriction: CGFloat = 0.0
    static let zeroDamping: CGFloat = 0.0
    static let physicsSpeed: CGFloat = 1.0

    /// Motion Constants
    static let impulseRange: ClosedRange<CGFloat> = -15.0...15.0
}

enum GameControllerConfig {
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
    @discardableResult
    static func spawnBubble(in scene: GameScene, avoiding cursorPosition: CGPoint? = nil) -> SKShapeNode {
        let selectedType = randomBubbleType()
        let position = randomPosition(in: scene, avoiding: cursorPosition)
        
        let bubble = makeBubbleNode(type: selectedType, at: position)
        scene.addChild(bubble)
        scene.controller?.bubblesSpawned += 1
        
        let randomImpulse = CGVector(
            dx: CGFloat.random(in: PhysicsConstants.impulseRange),
            dy: CGFloat.random(in: PhysicsConstants.impulseRange)
        )
        bubble.physicsBody?.applyImpulse(randomImpulse)
        
        return bubble
    }
    
    /// Selecting bubble type based on weighted probablity
    private static func randomBubbleType() -> BubbleConfig {
        let totalWeight = BubbleConfig.allCases.reduce(0) { $0 + $1.probability }
        let roll = Int.random(in: 1...totalWeight)
        var cumulative = 0
        for type in BubbleConfig.allCases {
            cumulative += type.probability
            if roll <= cumulative { return type }
        }
        return .red
    }
    
    /// Finds a valid random position within the scene bounds, avoiding the cursor if provided.
    private static func randomPosition(in scene: GameScene, avoiding cursorPosition: CGPoint?) -> CGPoint {
        let r = PhysicsConstants.bubbleRadius
        var position = CGPoint.zero
        
        for _ in 0..<50 {
            let x = CGFloat.random(in: r...(scene.size.width - r))
            let y = CGFloat.random(in: r...(scene.size.height - r))
            position = CGPoint(x: x, y: y)
            
            /// Accept any position if no cursor, otherwise ensure 100pt clearance
            guard let cursor = cursorPosition else { break }
            let distance = hypot(x - cursor.x, y - cursor.y)
            if distance > 100 { break }
        }
        return position
    }
    
    /// Builds and returns a configured bubble SKShapeNode.
    private static func makeBubbleNode(type: BubbleConfig, at position: CGPoint) -> SKShapeNode {
        let bubble = SKShapeNode(circleOfRadius: PhysicsConstants.bubbleRadius)
        bubble.name = PhysicsConstants.bubbleName
        bubble.fillColor = type.color
        bubble.strokeColor = .white
        bubble.lineWidth = 2
        bubble.position = position
        bubble.userData = ["points": type.points, "color": type.color]
        
        let body = SKPhysicsBody(circleOfRadius: PhysicsConstants.bubbleRadius)
        body.restitution = PhysicsConstants.perfectBounciness
        body.friction = PhysicsConstants.zeroFriction
        body.linearDamping = PhysicsConstants.zeroDamping
        body.allowsRotation = false
        bubble.physicsBody = body
        
        return bubble
    }
}
