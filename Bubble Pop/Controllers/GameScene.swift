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
    weak var controller: GameController?
    var playerName: String = ""
    
    /// Callback triggers when the game ends to handle UI navigation.
    var onReturnHome: (() -> Void)?
    
    private enum Constants {
        static let bubbleRadius: CGFloat = 30
        static let bubbleName = "Bubbles"
    }
    
    override func didMove(to view: SKView) {
        setupPhysics()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setupPhysics()
    }
    
    /// Configures the scene's boundary and global physics properties.
    func setupPhysics() {
        /// Creating an edge loop to keep bubbles contained within the screen bounds
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = borderBody
        /// Zero gravity environment for floating bubble movement
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    /// Creating and injects a new bubble node into the physics world with random properties.
    func generatingBubbles() {
        let bubble = SKShapeNode(circleOfRadius: Constants.bubbleRadius)
        bubble.name = Constants.bubbleName
        
        /// Retrieving randomised color and point values based on game probability
        let type = BubbleProbability.generateBubbleColor()
        
        bubble.fillColor = type.colour
        bubble.userData = ["points": type.points, "color": type.colour]
        
        /// Randomise initial position to ensure the bubble stays within boundaries
        bubble.position = CGPoint(
            x: CGFloat.random(in: Constants.bubbleRadius...frame.width - Constants.bubbleRadius),
            y: CGFloat.random(in: Constants.bubbleRadius...frame.height - Constants.bubbleRadius)
        )
        
        /// Configure physics for frictionless and bouncy movement
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: Constants.bubbleRadius)
        bubble.physicsBody?.restitution = 1.0
        bubble.physicsBody?.friction = 0
        bubble.physicsBody?.linearDamping = 0
        bubble.physicsBody?.allowsRotation = false
        
        addChild(bubble)
        
        /// Apply an initial velocity to set the bubble in motion
        let randomX = CGFloat.random(in: -15...15)
        let randomY = CGFloat.random(in: -15...15)
        bubble.physicsBody?.applyImpulse(CGVector(dx: randomX, dy: randomY))
    }
    
    /// Detects taps on bubble nodes and communicates scoring events to the controller.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes where node.name == Constants.bubbleName {
            if let pts = node.userData?["points"] as? Int,
               let clr = node.userData?["color"] as? UIColor {
                /// Notify controller of score change before removing the node
                controller?.handleTap(points: pts, color: clr)
                node.removeFromParent()
            }
        }
    }
    
    /// Resets the scene state and clears all active nodes for a new game session.
    func restartGameSession() {
        self.removeAllChildren()
        self.removeAllActions()
        
        self.isPaused = false
        self.physicsWorld.speed = 1.0

        setupPhysics()
        controller?.startGame()
    }
}

