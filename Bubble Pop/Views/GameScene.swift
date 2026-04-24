//
//  GameScene.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 26/3/2026.
//

import SwiftUI
import SpriteKit
import Observation

@Observable
class GameScene: SKScene {
    weak var controller: GameViewModel?
    var playerName: String = ""
    
    /// Callback triggers when the game ends to handle UI navigation.
    var onReturnHome: (() -> Void)?
    
    private var lastPositions: [SKNode: CGPoint] = [:]
    private var stuckFrameCounts: [SKNode: Int] = [:]
    private var lastBubbleColorPopped: UIColor?
    private var currentComboCount: Int = 0
    
    override func didMove(to view: SKView) {
        setupPhysics()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setupPhysics()
        maintainBubbleScreenBoundaries()
    }
    
    /// Configures the scene's boundary and global physics properties.
    func setupPhysics() {
        /// Creating an edge loop to keep bubbles contained within the screen bounds
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.gravity = .zero
        /// Zero gravity environment for floating bubble movement
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
    }
    
    /// Detects taps on bubble nodes and communicates scoring events to the controller.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstBubbleTouch = touches.first else { return }
        bubbleTapped(at: firstBubbleTouch.location(in: self))
    }
    
    private func bubbleTapped(at lastTapLocation: CGPoint) {
        for tappedNode in nodes(at: lastTapLocation) where tappedNode.name == PhysicsConstants.bubbleName {
            guard
                let bubblePoints = tappedNode.userData?["points"] as? Int,
                let bubbleColor = tappedNode.userData?["color"] as? UIColor
            else {
                continue
            }
            
            lastPositions.removeValue(forKey: tappedNode)
            stuckFrameCounts.removeValue(forKey: tappedNode)
            
            run(SKAction.playSoundFileNamed("bubblepop_sound.mp3", waitForCompletion: false))
            spawnPopParticles(at: tappedNode.position, color: bubbleColor, radius: tappedNode.frame.width / 2)
            let popSequence = SKAction.sequence([
                SKAction.scale(to: 1.3, duration: 0.08),
                SKAction.fadeOut(withDuration: 0.12),
                SKAction.removeFromParent()
            ])
            tappedNode.run(popSequence)
            controller?.handleTap(at: lastTapLocation, points: bubblePoints, color: bubbleColor)
            registerCombo(color: bubbleColor, at: tappedNode.position)
        }
    }

    func registerCombo(color: UIColor, at position: CGPoint) {
        if let last = lastBubbleColorPopped, last == color {
            currentComboCount += 1
        } else {
            currentComboCount = 1
        }
        lastBubbleColorPopped = color

        guard currentComboCount >= 2 else { return }

        run(SKAction.playSoundFileNamed("1.5x_combo_sound.mp3", waitForCompletion: false))

        let label = SKLabelNode(text: "\(currentComboCount)x COMBO")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 28
        label.fontColor = SKColor(cgColor: color.cgColor)
        label.position = position
        label.zPosition = 10
        addChild(label)

        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: 0, y: 60, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    /// Spawns small circle shards that fly outward from a popped bubble.
    private func spawnPopParticles(at position: CGPoint, color: UIColor, radius: CGFloat) {
        let particleCount = 10
        let particleRadius = radius * 0.18

        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let shard = SKShapeNode(circleOfRadius: particleRadius)
            shard.fillColor = color
            shard.strokeColor = .clear
            shard.position = position
            shard.zPosition = 5
            shard.alpha = 1.0
            addChild(shard)

            let distance = CGFloat.random(in: radius * 1.2...radius * 2.2)
            let jitter = CGFloat.random(in: -0.3...0.3)
            let dx = cos(angle + jitter) * distance
            let dy = sin(angle + jitter) * distance

            let fly = SKAction.moveBy(x: dx, y: dy, duration: 0.35)
            fly.timingMode = .easeOut
            let shrink = SKAction.scale(to: 0.1, duration: 0.35)
            let fade = SKAction.fadeOut(withDuration: 0.35)
            let group = SKAction.group([fly, shrink, fade])
            let remove = SKAction.removeFromParent()
            shard.run(SKAction.sequence([group, remove]))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let controller, !isPaused else { return }

        /// Speed scaling based on remaining time (EF1)
        let newSpeed: CGFloat
        switch controller.playTime {
        case ...10:  newSpeed = 5.0
        case ...30:  newSpeed = 3.5
        case ...60:  newSpeed = 2.0
        default:     newSpeed = 1.0
        }
        
        if physicsWorld.speed != newSpeed {
            physicsWorld.speed = newSpeed
        }
        detectAndReleaseStuckBubbles()
    }
    
    private func maintainBubbleScreenBoundaries() {
        guard size.width > 0, size.height > 0 else { return }
        for node in children where node.name == PhysicsConstants.bubbleName {
            let radius = node.frame.width / 2
            let clampedX = node.position.x.clamped(to: radius...(size.width - radius))
            let clampedY = node.position.y.clamped(to: radius...(size.height - radius))
            if node.position.x != clampedX || node.position.y != clampedY {
                node.position = CGPoint(x: clampedX, y: clampedY)
                nudgeStuckBubble(node)
            }
        }
    }
    
    /// Detects bubbles that haven't moved in several frames and re-launches them.
    private func detectAndReleaseStuckBubbles() {
        let stuckFrameThreshold = 3
        let minimumMovementThreshold: CGFloat = 0.5
        
        for node in children where node.name == PhysicsConstants.bubbleName {
            let currentPosition = node.position
            if let lastKnownPosition = lastPositions[node] {
                let hasMoved = abs(currentPosition.x - lastKnownPosition.x) >= minimumMovementThreshold
                        || abs(currentPosition.y - lastKnownPosition.y) >= minimumMovementThreshold
                if hasMoved {
                    stuckFrameCounts[node] = 0
                } else {
                    stuckFrameCounts[node, default: 0] += 1
                    if stuckFrameCounts[node, default: 0] >= stuckFrameThreshold {
                        nudgeStuckBubble(node)
                        stuckFrameCounts[node] = 0
                    }
                }
            }
            lastPositions[node] = currentPosition
        }
        /// Remove tracking entries for bubbles that no longer exist in the scene
        let activeBubble = Set(children.filter {
            $0.name == PhysicsConstants.bubbleName
        })
        lastPositions = lastPositions.filter {
            activeBubble.contains($0.key)
        }
        stuckFrameCounts = stuckFrameCounts.filter {
            activeBubble.contains($0.key)
        }
    }
    
    /// Applies a random velocity impulse directed away from the nearest
    /// screen edge to push a stuck bubble back into open play.
    private func nudgeStuckBubble(_ node: SKNode) {
        guard let physicsBody = node.physicsBody else {
            return
        }
        
        let edgeMargin: CGFloat = 40
        var horizontalDirection: CGFloat = CGFloat.random(in: -1...1)
        var verticalDirection: CGFloat = CGFloat.random(in: -1...1)
        
        /// Bias direction away from whichever edge the bubble is near
        if node.position.x < edgeMargin {
            horizontalDirection = abs(horizontalDirection)
        }
        if node.position.x > size.width - edgeMargin {
            horizontalDirection = -abs(horizontalDirection)
        }
        if node.position.y < edgeMargin {
            verticalDirection = abs(verticalDirection)
        }
        if node.position.y > size.height - edgeMargin {
            verticalDirection = -abs(verticalDirection)
        }
        
        /// Normalize the direction vector
        let magnitude = sqrt(horizontalDirection * horizontalDirection + verticalDirection * verticalDirection)
        if magnitude > 0 {
            horizontalDirection /= magnitude
            verticalDirection /= magnitude
        }
        
        let impulseStrength: CGFloat = physicsBody.mass * 80
        physicsBody.velocity = CGVector(
            dx: horizontalDirection * impulseStrength,
            dy: verticalDirection * impulseStrength
        )
    }
    
    func prepareToRestartSession() {
        self.removeAllChildren()
        self.removeAllActions()
        lastPositions.removeAll()
        stuckFrameCounts.removeAll()
        lastBubbleColorPopped = nil
        currentComboCount = 0
        self.isPaused = false
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
        setupPhysics()
    }
    
    /// Resets the scene state and clears all active nodes for a new game session.
    func restartGameSession() {
        self.removeAllChildren()
        self.removeAllActions()
        lastPositions.removeAll()
        stuckFrameCounts.removeAll()
        lastBubbleColorPopped = nil
        currentComboCount = 0
        self.isPaused = false
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
        setupPhysics()
        controller?.startGame()
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
