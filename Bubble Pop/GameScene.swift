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
    
    /// 1. Add this closure to talk to SwiftUI
    var onReturnHome: (() -> Void)?
    
    /// Referencing data collecting model
    var playerScore: PlayerData?
    
    /// Timer property
    var gameTimer: Timer?
    
    /// Total play time in seconds
    var playTime = 60 {
        didSet {
            if playTime <= 0 {
                stopTimer()
                endScoreBoard()
            }
        }
    }
    let timeLabel = SKLabelNode(fontNamed: "ArialMT")
    
    /// Called immediately after the scene is presented by a view.
    override func didMove(to view: SKView) {
        bubbleMove()
        startTimer()
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
        static let endScoreBoard = "Score Board"
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
        bubble.name = Constants.bubbleName
        
        /// Probability Logic
        let bubbleType = generateBubbleColor() // This returns a BubbleColours enum
        
        // FIX 1: Use the .colour property to get the actual UIColor
        bubble.fillColor = bubbleType.colour
        
        bubble.lineWidth = Constants.bubbleWidth
        bubble.alpha = Constants.bubbleAlpha
        
        /// Point based on colour assigned
        let points = bubbleType.points
        
        bubble.userData = ["points": points as NSNumber]
        
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
                
                // 1. Retrieve the points you just saved
                if let bubblePoints = node.userData?["points"] as? Int {
                    playerScore?.currentScore += bubblePoints
                } else {
                    playerScore?.currentScore += 1 // Fallback if points aren't found
                }
                /// Bubble effect before fading out after being popped
                let scaleOut = SKAction.scale(to: 1.2, duration: 0.1)
                let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                let remove = SKAction.removeFromParent()
                
                /// Run the sequence and check for game over AFTER the bubble is removed
                node.run(SKAction.sequence([scaleOut, fadeOut, remove])) { [weak self] in
                    self?.endScoreBoard()
                }
            }
        }
    }
    
    /// Game over screen when all bubbles are poppped
    func endScoreBoard() {
        
        /// Stop timer so it does not run in the background
        stopTimer()
        
        /// Add "Scoreboard"  label to the SpriteKit scene
        let remainingBubbles = children.filter {
            $0.name == Constants.bubbleName
        }
        /// Run if there are zero bubbles left
        if (playTime <= 0 || remainingBubbles.isEmpty) {
            stopTimer()
            
            if childNode(withName: Constants.endScoreBoard) == nil {
                let scoreBoard = SKLabelNode(text: Constants.endScoreBoard)
                scoreBoard.name = Constants.endScoreBoard
                let yPos = frame.midY + (frame.height * Constants.labelYOffset)
                scoreBoard.fontSize = 60
                scoreBoard.fontName = "AvenirNext-Bold"
                scoreBoard.fontColor = .black
                scoreBoard.position = CGPoint(x: frame.midX, y: yPos)
                scoreBoard.zPosition = 100
                addChild(scoreBoard)
                
                // Trigger the SwiftUI overlay
                onReturnHome?()
            }
        }
    }
    
    /// TIMER LOGIC
    func startTimer() {
        stopTimer() /// Stop any existing timer first
        playTime = 60 /// Resetting the time to 60 seconds
        
        /// Starting the timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else {
                return
            }
            
            if self.playTime > 0 {
                self.playTime -= 1
            } else {
                self.stopTimer()
                self.endScoreBoard()
            }
        }
    }
    
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    func resetGameScene() {
        self.removeAllChildren()
    }
    
    func restartGameSession() {
        /// Clear existing nodes (bubbles and labels)
        self.removeAllChildren()
        
        /// Re-setup the physics boundary (since removeAllChildren can affect certain setups)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        //// Spawn new bubbles
        for _ in 0..<Constants.bubbleCount {
            generatingBubbles()
        }
        startTimer()
    }
    // Clean up timer when scene is removed
    override func willMove(from view: SKView) {
        stopTimer()
    }
}


/// A SwiftUI wrapper that configures and presents the GameScene.
struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData /// Access the shared data
    @State private var showReturnButton = false
    
    @State private var gameScene: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 700)
        scene.scaleMode = .fill
        scene.backgroundColor = .white
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
            
            /// Score counter (Top left)
            if !showReturnButton {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: -5) {
                            Text("SCORE")
                                .font(.system(size: 14, weight: .light, design: .rounded))
                                .foregroundColor(.black)
                            
                            Text("\(playerData.currentScore)")
                                .font(.system(size: 45, weight: .light, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 25)
                        
                        Spacer()
                        
                        /// Display timer (Top right)
                        VStack(alignment: .trailing, spacing: -5) {
                            Text("TIME")
                                .font(.system(size: 14, weight: .light, design: .rounded))
                                .foregroundColor(.black)
                            
                            Text("\(gameScene.playTime)")
                                .font(.system(size: 45, weight: .light, design: .rounded))
                                .foregroundColor(gameScene.playTime <= 10 ? .red : .black)
                        }
                        .padding(.trailing, 25)
                    }
                    Spacer()
                }
            }
            
            /// Game over overlay
            if showReturnButton {
                VStack(spacing: 20) {
                    Spacer()
                    
                    /// 4. Display the score at the end
                    VStack {
                        Text("Final Score")
                            .font(.title2)
                            .foregroundColor(.black)
                        Text("\(playerData.currentScore)")
                            .font(.system(size: 40, weight: .light, design: .rounded))
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    // --- NEW RESTART BUTTON ---
                    Button(action: {
                        playerData.resetGame()           /// Reset score to 0
                        gameScene.restartGameSession()   /// Clear scene and spawn new bubbles
                        withAnimation {
                            showReturnButton = false     /// Hide the overlay
                        }
                    }) {
                        Text("Restart Game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)    /// Different color to distinguish it
                            .cornerRadius(15)
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        /// Clear the "Game Over" label and nodes
                        gameScene.resetGameScene()
                        playerData.resetGame() /// Reset the score
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
