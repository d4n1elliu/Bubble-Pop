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
    
    /// Closure to trigger SwiftUI overlay
    var onReturnHome: (() -> Void)?
    
    /// Referencing data collecting model
    var playerScore: PlayerData?
    
    /// Timer property
    var gameTimer: Timer?
    
    /// Remaining time in seconds and triggers endgame logic when reaching zero.
    var playTime = 60 {
        didSet {
            if playTime <= 0 {
                stopTimer()
                triggerEndGame()
            }
        }
    }
    
    ///. Perform initial scene setup and start the game.
    override func didMove(to view: SKView) {
        setupPhysics()
        startTimer()
    }
    
    private enum Constants {
        static let bubbleCount = 5
        static let bubbleRadius: CGFloat = 30
        static let bubbleAlpha: CGFloat = 0.7
        static let bubbleWidth : CGFloat = 2
        static let bubbleName = "Bubbles"
    }
    
    /// Configures scene physics and initialises the game world.
    func setupPhysics() {
        physicsWorld.gravity = .zero
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        
        for _ in 0..<Constants.bubbleCount {
            generatingBubbles()
        }
    }
    
    /// Spawns a bubble with randomised properties and initial physics impulse.
    func generatingBubbles() {
        let bubble = SKShapeNode(circleOfRadius: Constants.bubbleRadius)
        bubble.name = Constants.bubbleName
        
        let bubbleType = generateBubbleColor()
        bubble.fillColor = bubbleType.colour
        bubble.lineWidth = Constants.bubbleWidth
        bubble.alpha = Constants.bubbleAlpha
        
        let points = bubbleType.points
        bubble.userData = ["points": points as NSNumber]
        
        bubble.position = CGPoint(
            x: CGFloat.random(in: Constants.bubbleRadius...frame.width - Constants.bubbleRadius),
            y: CGFloat.random(in: Constants.bubbleRadius...frame.height - Constants.bubbleRadius)
        )
        
        bubble.physicsBody = SKPhysicsBody(circleOfRadius: Constants.bubbleRadius)
        bubble.physicsBody?.restitution = 0.5
        bubble.physicsBody?.friction = 0
        bubble.physicsBody?.linearDamping = 0
        bubble.physicsBody?.allowsRotation = false
        
        addChild(bubble)
        
        let randomX = CGFloat.random(in: -100...100)
        let randomY = CGFloat.random(in: -100...100)
        bubble.physicsBody?.applyImpulse(CGVector(dx: randomX, dy: randomY))
    }
    
    /// Handles bubble popping logic and score updates.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes where node.name == Constants.bubbleName {
            if let bubblePoints = node.userData?["points"] as? Int {
                playerScore?.currentScore += bubblePoints
            }
            
            let scaleOut = SKAction.scale(to: 1.2, duration: 0.1)
            let fadeOut = SKAction.fadeOut(withDuration: 0.1)
            let remove = SKAction.removeFromParent()
            
            node.run(SKAction.sequence([scaleOut, fadeOut, remove])) { [weak self] in
                self?.checkRemainingBubbles()
            }
        }
    }
    
    /// Evaluates remaining bubbles to determine if an win condition is met.
    func checkRemainingBubbles() {
        let remainingBubbles = children.filter { $0.name == Constants.bubbleName }
        if remainingBubbles.isEmpty {
            triggerEndGame()
        }
    }
    
    /// Terminates the game session and triggers the home transition.
    func triggerEndGame() {
        stopTimer()
        onReturnHome?() /// Triggers SwiftUI Overlay
    }
    
    /// Stat game session countdown
    func startTimer() {
        stopTimer()
        playTime = 60
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.playTime > 0 {
                self.playTime -= 1
            } else {
                self.triggerEndGame()
            }
        }
    }
    
    func stopTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    /// Resets the scene state and begins a fresh game session.
    func restartGameSession() {
        self.removeAllChildren()
        setupPhysics()
        startTimer()
    }
}

/// The root view for the bubble-popping game, bridging SpriteKit and SwiftUI.
struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData
    @Environment(ScoreManager.self) private var scoreManager
    @State private var showReturnButton = false
    
    /// Configures the SpriteKit scene with appropriate scaling and background.
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
                    gameScene.playerScore = playerData
                    gameScene.onReturnHome = {
                        withAnimation { showReturnButton = true }
                    }
                }
            
            /// HUD (Top Bar)
            VStack {
                HStack {
                    Text("Score: \(playerData.currentScore)")
                    Spacer()
                    Text("Time: \(gameScene.playTime)")
                        .foregroundColor(gameScene.playTime <= 10 ? .red : .primary)
                }
                .font(.system(.headline, design: .rounded))
                .padding()
                Spacer()
            }
            .allowsHitTesting(false)
            
            /// End Screen Overlay
            if showReturnButton {
                VStack(spacing: 25) {
                    Text(gameScene.playTime <= 0 ? "TIME'S UP!" : "WELL DONE!")
                        .font(.system(size: 40, weight: .black))
                    
                    VStack(spacing: 5) {
                        Text("Final Score")
                        Text("\(playerData.currentScore)")
                            .font(.system(size: 60, weight: .light))
                        
                        Text("Personal Best: \(scoreManager.highScore)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Restart Game") {
                        playerData.currentScore = 0
                        showReturnButton = false
                        gameScene.restartGameSession()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Main Menu") {
                        playerData.currentScore = 0
                        dismiss()
                    }
                }
                .padding(40)
                .background(RoundedRectangle(cornerRadius: 25).fill(.white).shadow(radius: 10))
                .onAppear {
                    scoreManager.updateHighScore(with: playerData.currentScore)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

/// Injecting dependencies for preview rendering.
#Preview {
    ContentView()
    .environment(PlayerData())
    .environment(ScoreManager())
}
