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
    static let bubbleBounciness: CGFloat = 1.0
    static let bubbleFriction: CGFloat = 0.0
    static let bubbleDamping: CGFloat = 0.0
    static let physicsSpeed: CGFloat = 1.0
    static let impulseRange: ClosedRange<CGFloat> = -15.0...15.0
}

// Static configure for core game loop and spawning logic
enum GameControllerConfig {

    static let initialPlayTime: Int = 60
    static let maxBubbles: Int = 15
    static let timerInterval: TimeInterval = 1.0
    static let initialScore: Int = 0
    static let initialSpawnCount: Int = 0
    static let physicsCleanupDelay: Double = 0.15
    
    /// Node name for identifying and filter bubble entities within the scene graphs
    static let bubbleNodeName = "Bubbles"
}

/// Defined the five bubble variants, each with a distinct point value, spawn probability and colour.
/// Probability are relative weights which sums up to 100, making it unreadable as percentages
/// High valued bubbles are assigned lower weights to perserve game balance
enum BubbleConfig: CaseIterable {
    case red, pink, green, blue, black
    
    /// Score awarded to player when this bubble type is popped.
    var points: Int {
        switch self {
            case .red:   return 1
            case .pink:  return 2
            case .green: return 5
            case .blue:  return 8
            case .black: return 10
        }
    }
    /// Spawn probability out of 100 percent, using random weighted selection to control how frequent each type appears.
    var probability: Int {
        switch self {
            case .red:   return 40
            case .pink:  return 30
            case .green: return 15
            case .blue:  return 10
            case .black: return 5
        }
    }
    
    /// Fill color of each bubble, needs to apply to bubble's SKShapeNode
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

/// Bubble static factory methods for constructing and spawn bubbles nodes.
struct BubbleCreation {
    
    /// Spawns a single bubble with randomised type, position and impluse.
    @discardableResult
    static func spawnBubble(in scene: GameScene, avoiding cursorPosition: CGPoint? = nil) -> SKShapeNode {
        let selectedType = randomBubbleType()
        let position = randomPosition(in: scene, avoiding: cursorPosition)
        
        let bubble = makeBubbleNode(type: selectedType, at: position)
        scene.addChild(bubble)
        scene.controller?.bubblesSpawned += 1
        
        /// Apply an randomised impluse to give each bubble an unique starting direction and speed.
        let randomImpulse = CGVector(
            dx: CGFloat.random(in: PhysicsConstants.impulseRange),
            dy: CGFloat.random(in: PhysicsConstants.impulseRange)
        )
        bubble.physicsBody?.applyImpulse(randomImpulse)
        
        return bubble
    }
    
    /// Select a bubble type using random weighted random sampling
    /// A single random roll is compared against all cumlative probability thresholds, ensuring each type appearing with frequency by defining its probability weight.
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
    
    /// Determing a valid spawn location within the scene bounds
    /// Spawn location is 100 points away from the provided cursor position
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
    
    /// Constructs a fully configured 
    private static func makeBubbleNode(type: BubbleConfig, at position: CGPoint) -> SKShapeNode {
        let bubble = SKShapeNode(circleOfRadius: PhysicsConstants.bubbleRadius)
        bubble.name = PhysicsConstants.bubbleName
        bubble.fillColor = type.color
        bubble.strokeColor = SKColor(white: 0.0, alpha: 0.25)
        bubble.lineWidth = 2.5
        bubble.position = position
        bubble.userData = ["points": type.points, "color": type.color]
        
        let body = SKPhysicsBody(circleOfRadius: PhysicsConstants.bubbleRadius)
        body.restitution = PhysicsConstants.bubbleBounciness
        body.friction = PhysicsConstants.bubbleFriction
        body.linearDamping = PhysicsConstants.bubbleDamping
        body.allowsRotation = false
        bubble.physicsBody = body
        
        return bubble
    }
}
