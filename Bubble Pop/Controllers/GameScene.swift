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
        setupPhysics()
        controller?.startGame()
    }
}

/// The root view for the bubble-popping game, bridging SpriteKit and SwiftUI.
struct GameView: View {
    let playerName: String
    @Environment(\.dismiss) private var dismiss
    @Environment(PlayerData.self) private var playerData
    @Environment(ScoreManager.self) private var scoreManager
    
    @State private var showReturnButton = false
    @State private var showScoreBoard = false
    @State private var controller: GameController?
    
    @State private var gameScene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        scene.backgroundColor = SKColor(red: 255/255, green: 240/255, blue: 240/255, alpha: 1.0)
        return scene
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            /// HUD
            HStack {
                statColumn(title: "Time Left", value: "\(controller?.playTime ?? 60)",
                           color: (controller?.playTime ?? 60) <= 10 ? .red : .primary)
                Spacer()
                statColumn(title: "Score", value: "\(playerData.currentScore)")
                Spacer()
                statColumn(title: "High Score", value: "\(scoreManager.highScore)")
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            
            /// Game Layer
            GeometryReader { geo in
                ZStack {
                    SpriteView(scene: gameScene, options: [.allowsTransparency])
                        .onAppear {
                            gameScene.size = geo.size
                            setupGame()
                        }
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .navigationBarBackButtonHidden(true)
        .overlay {
            if showReturnButton { endGameOverlay }
        }
        .sheet(isPresented: $showScoreBoard) { ScoreBoardView() }
    }
    
    private func statColumn(title: String, value: String, color: Color = .primary) -> some View {
        VStack(spacing: 6) {
            Text(title).font(.system(size: 16, weight: .semibold))
            Text(value).font(.system(size: 18, weight: .medium, design: .monospaced)).foregroundColor(color)
        }
    }
    
    private func setupGame() {
    
        if controller == nil {
            controller = GameController(player: playerData, scoreManager: scoreManager)
        }
        
        guard let gc = controller else { return }
        
        gameScene.controller = gc
        gc.scene = gameScene
        
        gc.playerScore = Binding<Int>(
            get: { playerData.currentScore },
            set: { playerData.currentScore = $0 }
        )
        
        gameScene.playerName = playerName
        gameScene.onReturnHome = {
            withAnimation(.spring()) {
                showReturnButton = true
                scoreManager.updateHighScore(with: playerData.currentScore, playerName: playerName)
            }
        }
        
        gc.startGame()
    }
    
    private var endGameOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea().transition(.opacity)
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text(controller?.playTime ?? 0 <= 0 ? "TIME'S UP!" : "GAME OVER")
                        .font(.system(size: 32, weight: .black, design: .rounded))
                    
                    Text(playerName.uppercased())
                        .font(.headline).foregroundColor(.secondary)
                }
                
                VStack(spacing: 4) {
                    Text("FINAL SCORE").font(.caption).bold().tracking(2)
                    Text("\(playerData.currentScore)").font(.system(size: 70, weight: .black, design: .rounded))
                }
                
                VStack(spacing: 12) {
                    buttonCapsule("Restart Game", color: .blue) {
                        playerData.currentScore = 0
                        showReturnButton = false
                        gameScene.restartGameSession()
                    }
                    
                    buttonCapsule("Scoreboard", color: .orange) {
                        showScoreBoard = true
                    }
                    
                    buttonCapsule("Main Menu", color: .gray.opacity(0.2), textColor: .primary) {
                        playerData.currentScore = 0
                        dismiss()
                    }
                }
            }
            .padding(35)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 35))
            .padding(.horizontal, 40)
        }
    }
    
    private func buttonCapsule(_ text: String, color: Color, textColor: Color = .white, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .foregroundColor(textColor)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    GameView(playerName: "Player 1")
        .environment(PlayerData())
        .environment(ScoreManager())
}
