//
//  GameScene.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 26/3/2026.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    func bubbleMove() {
        // Set up physics (gravity)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        // Generate random bubbles
        for _ in 0..<10 {
            generatingBubbles()
        }
    }
    func generatingBubbles() {
        let size : CGFloat = 50
        let bubble = SKShapeNode(circleOfRadius: size)
        bubble.fillColor = .white
        bubble.strokeColor = .cyan
        bubble.lineWidth = 2
        bubble.alpha = 0.7
        
        // Bubble random spawn location
        bubble.position = CGPoint(
            x: CGFloat.random(in: size...frame.width - size),
            y: CGFloat.random(in: size...frame.height - size)
        )
        
        // Add Bubble Physics
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: size / 2)
        bubble.physicsBody?.restitution = 0.8 // Bouncy
        bubble.physicsBody?.linearDamping = 0.5 // Slow down
                
        addChild(bubble)
                
        // Float up action
        let moveUp = SKAction.moveBy(x: 0, y: frame.height, duration: TimeInterval.random(in: 2...5))
        let remove = SKAction.removeFromParent()
        bubble.run(SKAction.sequence([moveUp, remove]))
    }
}

// 2. Wrap up the scene in SwiftUI View
struct GameView: View {
    var scene: SKScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 700)
        scene.scaleMode = .fill
        return scene
    }
        
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}
