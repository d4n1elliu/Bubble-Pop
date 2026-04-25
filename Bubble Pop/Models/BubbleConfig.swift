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
    static let bubbleImpulseRange: ClosedRange<CGFloat> = -15.0...15.0
    static let bubbleCursorClearance: CGFloat = 100.0
    static let bubbleStrokeWidth: CGFloat = 2.5
    static let bubbleStrokeOpacity: CGFloat = 0.25
    static let bubbleStrokeWhite: CGFloat = 0.0
    static let spawnMaxAttempts: Int = 50
}

enum GameControllerConfig {
    static let initialPlayTime: Int = 60
    static let maxBubbles: Int = 15
    static let timerInterval: TimeInterval = 1.0
    static let initialScore: Int = 0
    static let initialSpawnCount: Int = 0
    static let physicsCleanupDelay: Double = 0.15
    static let bubbleNodeName = "Bubbles"
    static let unknownPlayerName: String = "Unknown"
    static let comboMultiplier: Double = 1.5
    static let initialSpawnDelay: Double = 0.2
    static let bubbleFadeInDuration: Double = 0.3
    static let bubbleFadeOutDuration: Double = 0.25
    static let minBubbleRemoval: Int = 1
    static let maxBubbleRemoval: Int = 3
    static let speedFast: CGFloat = 5.0
    static let speedMedium: CGFloat = 3.5
    static let speedNormal: CGFloat = 2.0
    static let speedSlow: CGFloat = 1.0
    static let speedThresholdLow: Int = 10
    static let speedThresholdMid: Int = 30
    static let speedThresholdHigh: Int = 60
    static let stuckFrameThreshold: Int = 3
    static let minimumMovementThreshold: CGFloat = 0.5
    static let edgeMargin: CGFloat = 40
    static let impulseStrengthMultiplier: CGFloat = 80
    static let particleCount: Int = 10
    static let particleRadiusRatio: CGFloat = 0.18
    static let particleMinDistance: CGFloat = 1.2
    static let particleMaxDistance: CGFloat = 2.2
    static let particleJitterRange: CGFloat = 0.3
    static let particleAnimDuration: CGFloat = 0.35
    static let particleShrinkScale: CGFloat = 0.1
    static let popScaleTo: CGFloat = 1.3
    static let popScaleDuration: Double = 0.08
    static let popFadeDuration: Double = 0.12
    static let comboLabelFontSize: CGFloat = 28
    static let comboLabelMoveY: CGFloat = 60
    static let comboLabelAnimDuration: Double = 0.6
    static let comboMinCount: Int = 2
    static let popSoundFile: String = "bubblepop_sound.mp3"
    static let comboSoundFile: String = "1.5x_combo_sound.mp3"
    static let comboLabelFont: String = "AvenirNext-Bold"
    static let comboLabelZPosition: CGFloat = 10
    static let particleZPosition: CGFloat = 5
    static let particleInitialAlpha: CGFloat = 1.0
    static let nudgeDirectionRange: ClosedRange<CGFloat> = -1.0...1.0
    static let fullCircleRadians: CGFloat = .pi * 2
}

enum BubbleConfig: CaseIterable {
    case red, pink, green, blue, black
    
    var bubblePoints: Int {
        switch self {
        case .red:   return 1
        case .pink:  return 2
        case .green: return 5
        case .blue:  return 8
        case .black: return 10
        }
    }
    var bubbleSpawnProbability: Int {
        switch self {
        case .red:   return 40
        case .pink:  return 30
        case .green: return 15
        case .blue:  return 10
        case .black: return 5
        }
    }
    
    var bubbleColor: UIColor {
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
    @discardableResult
    /// - Parameters:
    ///   - scene: The active GameScene where the bubble will spawn into
    ///   - cursorPosition: Optional screen position to avoid spawning near cursor
    static func spawnBubble(in scene: GameScene, avoiding cursorPosition: CGPoint? = nil) -> SKShapeNode {
        let bubbleType = randomBubbleType()
        let bubbleSpawnPosition = randomPosition(in: scene, avoiding: cursorPosition)
        let bubbleNode = makeBubbleNode(type: bubbleType, at: bubbleSpawnPosition)
        scene.addChild(bubbleNode)
        
        let randomLaunchImpulse = CGVector(
            dx: CGFloat.random(in: PhysicsConstants.bubbleImpulseRange),
            dy: CGFloat.random(in: PhysicsConstants.bubbleImpulseRange)
        )
        bubbleNode.physicsBody?.applyImpulse(randomLaunchImpulse)
        return bubbleNode
    }
    
    private static func randomBubbleType() -> BubbleConfig {
        let totalProbabilityWeight = BubbleConfig.allCases.reduce(0) { $0 + $1.bubbleSpawnProbability }
        let randomRoll = Int.random(in: 1...totalProbabilityWeight)
        var cumulativeProbability = 0
        for bubbleType in BubbleConfig.allCases {
            cumulativeProbability += bubbleType.bubbleSpawnProbability
            if randomRoll <= cumulativeProbability { return bubbleType }
        }
        return .red
    }
    
    /// - Parameters:
    ///   - scene: The active GameScene whose bounds define the valid spawn area
    ///   - cursorPosition: Optional cursor position to prevent bubbles from spawning on top of cursor
    private static func randomPosition(in scene: GameScene, avoiding cursorPosition: CGPoint?) -> CGPoint {
        let bubbleRadius = PhysicsConstants.bubbleRadius
        var candidatePosition = CGPoint.zero
        
        for _ in 0..<PhysicsConstants.spawnMaxAttempts {
            let randomX = CGFloat.random(in: bubbleRadius...(scene.size.width - bubbleRadius))
            let randomY = CGFloat.random(in: bubbleRadius...(scene.size.height - bubbleRadius))
            candidatePosition = CGPoint(x: randomX, y: randomY)
            guard let cursor = cursorPosition else { break }
            let distanceFromCursor = hypot(randomX - cursor.x, randomY - cursor.y)
            if distanceFromCursor > PhysicsConstants.bubbleCursorClearance { break }
        }
        return candidatePosition
    }
    
    /// - Parameters:
    ///   - type: The BubbleConfig case to define bubble color, points and spawn probability
    ///   - position: The exact spawn coordinates to place the bubble node at
    private static func makeBubbleNode(type: BubbleConfig, at position: CGPoint) -> SKShapeNode {
        let node = SKShapeNode(circleOfRadius: PhysicsConstants.bubbleRadius)
        node.name = PhysicsConstants.bubbleName
        node.fillColor = type.bubbleColor
        node.strokeColor = SKColor(white: PhysicsConstants.bubbleStrokeWhite, alpha: PhysicsConstants.bubbleStrokeOpacity)
        node.lineWidth = PhysicsConstants.bubbleStrokeWidth
        node.position = position
        node.userData = ["points": type.bubblePoints, "color": type.bubbleColor]
        
        let physics = SKPhysicsBody(circleOfRadius: PhysicsConstants.bubbleRadius)
        physics.restitution = PhysicsConstants.bubbleBounciness
        physics.friction = PhysicsConstants.bubbleFriction
        physics.linearDamping = PhysicsConstants.bubbleDamping
        physics.allowsRotation = false
        node.physicsBody = physics
        
        return node
    }
}
