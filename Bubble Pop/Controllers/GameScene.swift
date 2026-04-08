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
    
    func setupPhysics() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    func generatingBubbles() {
        let bubble = SKShapeNode(circleOfRadius: Constants.bubbleRadius)
        bubble.name = Constants.bubbleName
        let type = BubbleProbability.generateBubbleColor()
        
        bubble.fillColor = type.colour
        bubble.userData = ["points": type.points, "color": type.colour]
        
        bubble.position = CGPoint(
            x: CGFloat.random(in: Constants.bubbleRadius...frame.width - Constants.bubbleRadius),
            y: CGFloat.random(in: Constants.bubbleRadius...frame.height - Constants.bubbleRadius)
        )
        
        /// Physics Body setup
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: Constants.bubbleRadius)
        bubble.physicsBody?.restitution = 1.0
        bubble.physicsBody?.friction = 0
        bubble.physicsBody?.linearDamping = 0
        bubble.physicsBody?.allowsRotation = false
        
        addChild(bubble)
        
        let randomX = CGFloat.random(in: -15...15)
        let randomY = CGFloat.random(in: -15...15)
        bubble.physicsBody?.applyImpulse(CGVector(dx: randomX, dy: randomY))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes where node.name == Constants.bubbleName {
            if let pts = node.userData?["points"] as? Int,
               let clr = node.userData?["color"] as? UIColor {
                controller?.handleTap(points: pts, color: clr)
                node.removeFromParent()
            }
        }
    }
    
    func restartGameSession() {
        self.removeAllChildren()
        self.removeAllActions()
        
        self.isPaused = false
        self.physicsWorld.speed = 1.0

        setupPhysics()
        controller?.startGame()
    }
}

