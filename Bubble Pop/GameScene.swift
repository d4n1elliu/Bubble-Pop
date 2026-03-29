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
     
    private enum Constants {
        static let bubbleCount = 5
        static let bubbleRadius: CGFloat = 30
        static let initialImpulseRange: CGFloat = 100
        static let labelYOffset: CGFloat = 0.3
        static let bubbleAlpha: CGFloat = 0.7
        static let popDuration: TimeInterval = 0.1
        static let popScale: CGFloat = 1.2
        static let bubbleWidth : CGFloat = 2
        /// String constants (Prevent typos)
        static let bubbleName = "Bubbles"
        static let gameOverText = "Game Over"
    }
    
    /// Configures the global physics environment and triggers the initial bubble spawn.
    func bubbleMove() {
        
        /// Disable gravity so bubbles don't fall at start
        physicsWorld.gravity = .zero
        
        /// Create an invisible boundary around the screen edge to keep bubbles contained
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        /// Initialize the game world with a set number of bubbles
        for _ in 0..<Constants.bubbleCount {
            generatingBubbles()
        }
    }
    
    /// Creates a single bubble node with physics properties and an initial kinetic impulse.
    func generatingBubbles() {
        let bubble = SKShapeNode(circleOfRadius: Constants.bubbleRadius)
        /// Identifer used for hit-testing in touch events
        bubble.name = Constants.bubbleName
        /// Bubble visual styling
        bubble.fillColor = .white
        bubble.strokeColor = .cyan
        bubble.lineWidth = Constants.bubbleWidth
        bubble.alpha = Constants.bubbleAlpha
        
        bubble.position = CGPoint(
            x: CGFloat.random(in: Constants.bubbleRadius...frame.width - Constants.bubbleRadius),
            y: CGFloat.random(in: Constants.bubbleRadius...frame.height - Constants.bubbleRadius)
        )
        
        /// Ensures elastic collisions and frictionless movement
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: Constants.bubbleRadius)
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
            if node.name == Constants.bubbleName {
                
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
        let remainingBubbleCheck = children.filter{ $0.name == Constants.bubbleName}
        // ONLY run this code if there are zero bubbles left
        if remainingBubbleCheck.isEmpty {
            let gameOverLabel = SKLabelNode(text: Constants.gameOverText)
            let yPos = frame.midY + (frame.height * Constants.labelYOffset)
            
            gameOverLabel.fontSize = 50
            gameOverLabel.fontName = "AvenirNext-Bold"
            gameOverLabel.zPosition = 100
            gameOverLabel.fontColor = .red
            gameOverLabel.position = CGPoint(x: frame.midX, y: yPos)
            
            addChild(gameOverLabel)
            
            // Trigger the SwiftUI overlay
            onReturnHome?()
        }
    }
    
    func resetGameScene() {
        self.removeAllChildren()
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
            
            /// --- TOP LEFT SCORE COUNTER ---
            if !showReturnButton {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: -5) {
                            Text("SCORE")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(playerData.currentScore)")
                                .font(.system(size: 45, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.leading, 25)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                    Spacer()
                }
            }
            
            /// --- GAME OVER OVERLAY ---
            if showReturnButton {
                VStack(spacing: 20) {
                    Spacer()
                    
                    /// 4. Display the score at the end
                    VStack {
                        Text("Final Score")
                            .font(.title2)
                            .foregroundColor(.white)
                        Text("\(playerData.currentScore)")
                            .font(.system(size: 60, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    Button(action: {
                        /// Clear the "Game Over" label and nodes
                        gameScene.resetGameScene()
                        playerData.resetGame() // Reset the score
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
