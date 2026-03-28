//
//  GameScene.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 26/3/2026.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
    
    /// 1. Add this closure to talk to SwiftUI
    var onReturnHome: (() -> Void)?
    
    /// Referencing data collecting model
    var playerScore: PlayerData?
    
    /// Called immediately after the scene is presented by a view.
    override func didMove(to view: SKView) {
        bubbleMove()
    }
    
    /// Configures the global physics environment and triggers the initial bubble spawn.
    func bubbleMove() {
        
        /// Disable gravity so bubbles don't fall at start
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        /// Create an invisible boundary around the screen edge to keep bubbles contained
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        /// Initialize the game world with a set number of bubbles
        for _ in 0..<5 {
            generatingBubbles()
        }
    }
    
    /// Creates a single bubble node with physics properties and an initial kinetic impulse.
    func generatingBubbles() {
        let radius: CGFloat = 30
        let bubble = SKShapeNode(circleOfRadius: radius)
        
        /// Identifer used for hit-testing in touch events
        bubble.name = "Bubbles"
        
        /// Bubble visual styling 
        bubble.fillColor = .white
        bubble.strokeColor = .cyan
        bubble.lineWidth = 2
        bubble.alpha = 0.7
        
        bubble.position = CGPoint(
            x: CGFloat.random(in: radius...frame.width - radius),
            y: CGFloat.random(in: radius...frame.height - radius)
        )
        
        /// Ensures elastic collisions and frictionless movement
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        bubble.physicsBody?.restitution = 0.5 // Perfect bounce (no energy lost)
        bubble.physicsBody?.friction = 0
        bubble.physicsBody?.linearDamping = 0 // No air resistance
        bubble.physicsBody?.allowsRotation = false
        
        addChild(bubble)
        
        /// Apply a random initial velocity to start the 'floating' movement
        let randomX = CGFloat.random(in: -100...100)
        let randomY = CGFloat.random(in: -100...100)
        bubble.physicsBody?.applyImpulse(CGVector(dx: randomX, dy: randomY))
    }
    /// Detects user taps and removes the corresponding bubble with a 'pop' animation.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node.name == "Bubbles" {
                
                ///Imcrementing score by 1 per bubble click
                playerScore?.currentScore += 1
                /// Bubble effect before fading out after being popped
                let scaleOut = SKAction.scale(to: 1.2, duration: 0.1)
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                let remove = SKAction.removeFromParent()
                
                /// Run the sequence and check for game over AFTER the bubble is removed
                node.run(SKAction.sequence([scaleOut, fadeOut, remove])) { [weak self] in
                    self?.gameOver()
                }
            }
        }
    }
    
    /// Game over screen when all bubbles are poppped
    func gameOver() {
        let remainingBubbleCheck = children.filter{ $0.name == "Bubbles"}
        if remainingBubbleCheck.isEmpty {
            let gameOverLabel = SKLabelNode(text: "Game Over")
            gameOverLabel.fontSize = 50
            gameOverLabel.zPosition = 100
            gameOverLabel.fontColor = .red
            gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 200)
            addChild(gameOverLabel)
            
            // 2. Instead of a SpriteKit button (which is hard to style),
                        // we will trigger the SwiftUI overlay in the next step.
            onReturnHome?()
        }
    }
}

/// A SwiftUI wrapper that configures and presents the GameScene.
struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData // Access the shared data
    @State private var showReturnButton = false
    
    @State private var gameScene: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 700)
        scene.scaleMode = .fill
        scene.backgroundColor = .systemBlue
        return scene
    }()
        
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()
                .onAppear {
                    // 3. Link the data model to the scene
                    gameScene.playerScore = playerData
                    
                    gameScene.onReturnHome = {
                        withAnimation {
                            showReturnButton = true
                        }
                    }
                }
            
            if showReturnButton {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // 4. Display the score at the end
                    VStack {
                        Text("Final Score")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("\(playerData.currentScore)")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundColor(.yellow) // Make the score stand out
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    Button(action: {
                        playerData.resetGame() // Reset score for next time
                        dismiss()
                    }) {
                        Text("Return to Home")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ContentView()
        .environment(PlayerData())
}
