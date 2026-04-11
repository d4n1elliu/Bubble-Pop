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
        self.physicsWorld.gravity = .zero
        /// Zero gravity environment for floating bubble movement
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
    }
    
    /// Detects taps on bubble nodes and communicates scoring events to the controller.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes where node.name == PhysicsConstants.bubbleName {
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
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed

        setupPhysics()
        controller?.startGame()
    }
}

