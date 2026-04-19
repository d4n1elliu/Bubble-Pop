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
            controller?.handleTap(at: lastTapLocation, points: bubblePoints, color: bubbleColor)
            tappedNode.removeFromParent()
        }
    }
    override func update(_ currentTime: TimeInterval) {
        /// Ensure we have access to the controller and the game is active
        guard let controller = controller, !self.isPaused else {
            return
        }
        
        /// This example increases speed as time drops below certain thresholds
        let newSpeed: CGFloat
        if controller.playTime <= 10 {
            newSpeed = 5 /// Final 10 seconds: Very fast
        }
        else if controller.playTime <= 30 {
            newSpeed = 3.5/// Under 30 seconds: Faster
        }
        else if controller.playTime <= 60 {
            newSpeed = 2
        }
        else {
            newSpeed = 1.0 /// Normal speed
        }
        
        /// Applying speed to the physics world
        /// We use a small check to avoid re-setting it every single frame if it hasn't changed
        if self.physicsWorld.speed != newSpeed {
            self.physicsWorld.speed = newSpeed
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
                let horizontalDelta = abs(currentPosition.x - lastKnownPosition.x)
                let verticalDelta = abs(currentPosition.y - lastKnownPosition.y)
                
                if horizontalDelta < minimumMovementThreshold && verticalDelta < minimumMovementThreshold {
                    stuckFrameCounts[node, default: 0] += 1
                    if stuckFrameCounts[node, default: 0] >= stuckFrameThreshold {
                        nudgeStuckBubble(node)
                        stuckFrameCounts[node] = 0
                    }
                } else {
                    stuckFrameCounts[node] = 0
                }
            }
            lastPositions[node] = currentPosition
        }
        
        /// Remove tracking entries for bubbles that no longer exist in the scene
        let activeBubbleNodes = Set(children.filter {
            $0.name == PhysicsConstants.bubbleName
        })
        lastPositions = lastPositions.filter {
            activeBubbleNodes.contains($0.key)
        }
        stuckFrameCounts = stuckFrameCounts.filter {
            activeBubbleNodes.contains($0.key)
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
    
    /// Resets the scene state and clears all active nodes for a new game session.
    func restartGameSession() {
        self.removeAllChildren()
        self.removeAllActions()
        lastPositions.removeAll()
        stuckFrameCounts.removeAll()
        
        self.isPaused = false
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
        setupPhysics()
        controller?.startGame()
    }
}

/// Convenience clamp for CGFloat ranges
private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
