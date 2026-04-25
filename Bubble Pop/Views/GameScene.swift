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
    var onReturnHome: (() -> Void)?
    
    private var lastKnownBubblePositions: [SKNode: CGPoint] = [:]
    private var stuckBubbleFrameCounts: [SKNode: Int] = [:]
    private var lastPoppedBubbleColor: UIColor?
    private var consecutiveComboCount: Int = GameControllerConfig.initialComboCount
    
    override func didMove(to view: SKView) {
        setupPhysics()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        setupPhysics()
        maintainBubbleScreenBoundaries()
    }
    
    func setupPhysics() {
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        self.physicsBody = borderBody
        self.physicsWorld.gravity = .zero
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
    }
    
    /// - Parameters:
    ///   - touches: The set of touches that began on the screen
    ///   - event: The event associated with the touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let firstBubbleTouch = touches.first else { return }
        bubbleTapped(at: firstBubbleTouch.location(in: self))
    }
    
    /// - Parameters:
    ///   - lastTapLocation: The screen coordinate of the tap
    private func bubbleTapped(at lastTapLocation: CGPoint) {
        for tappedNode in nodes(at: lastTapLocation) where tappedNode.name == PhysicsConstants.bubbleName {
            guard
                let bubblePoints = tappedNode.userData?["points"] as? Int,
                let bubbleColor = tappedNode.userData?["color"] as? UIColor
            else {
                continue
            }
            lastKnownBubblePositions.removeValue(forKey: tappedNode)
            stuckBubbleFrameCounts.removeValue(forKey: tappedNode)
            run(SKAction.playSoundFileNamed(GameControllerConfig.popSoundFile, waitForCompletion: false))
            spawnPopParticles(at: tappedNode.position, color: bubbleColor, radius: tappedNode.frame.width / PhysicsConstants.bubbleDiameterDivisor)
            let popSequence = SKAction.sequence([
                SKAction.scale(to: GameControllerConfig.popScaleTo, duration: GameControllerConfig.popScaleDuration),
                SKAction.fadeOut(withDuration: GameControllerConfig.popFadeDuration),
                SKAction.removeFromParent()
            ])
            tappedNode.run(popSequence)
            controller?.handleTap(at: lastTapLocation, points: bubblePoints, color: bubbleColor)
            registerCombo(color: bubbleColor, at: tappedNode.position)
        }
    }
    
    /// - Parameters:
    ///   - color: The popped bubble's color that used to detect if a combo is active
    ///   - position: The location to display the combo label on screen
    func registerCombo(color: UIColor, at position: CGPoint) {
        if let last = lastPoppedBubbleColor, last == color {
            consecutiveComboCount += 1
        } else {
            consecutiveComboCount = GameControllerConfig.firstComboCount
        }
        lastPoppedBubbleColor = color
        guard consecutiveComboCount >= GameControllerConfig.comboMinCount else { return }
        run(SKAction.playSoundFileNamed(GameControllerConfig.comboSoundFile, waitForCompletion: false))
        let label = SKLabelNode(text: "\(consecutiveComboCount)x COMBO")
        label.fontName = GameControllerConfig.comboLabelFont
        label.fontSize = GameControllerConfig.comboLabelFontSize
        label.fontColor = SKColor(cgColor: color.cgColor)
        label.position = position
        label.zPosition = GameControllerConfig.comboLabelZPosition
        addChild(label)
        label.run(SKAction.sequence([
            SKAction.group([
                SKAction.moveBy(x: GameControllerConfig.comboLabelMoveX, y: GameControllerConfig.comboLabelMoveY, duration: GameControllerConfig.comboLabelAnimDuration),
                SKAction.fadeOut(withDuration: GameControllerConfig.comboLabelAnimDuration)
            ]),
            SKAction.removeFromParent()
        ]))
    }
    
    /// - Parameters:
    ///   - position: Where to spawn the particles on screen
    ///   - color: The popped bubble's color applied to the particles
    ///   - radius: The popped bubble's radius used to scale how far particles spread
    private func spawnPopParticles(at position: CGPoint, color: UIColor, radius: CGFloat) {
        let particleCount = GameControllerConfig.particleCount
        let particleRadius = radius * GameControllerConfig.particleRadiusRatio

        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * GameControllerConfig.fullCircleRadians
            let shard = SKShapeNode(circleOfRadius: particleRadius)
            shard.fillColor = color
            shard.strokeColor = .clear
            shard.position = position
            shard.zPosition = GameControllerConfig.particleZPosition
            shard.alpha = GameControllerConfig.particleInitialAlpha
            addChild(shard)
            let distance = CGFloat.random(in: radius * GameControllerConfig.particleMinDistance...radius * GameControllerConfig.particleMaxDistance)
            let jitter = CGFloat.random(in: -GameControllerConfig.particleJitterRange...GameControllerConfig.particleJitterRange)
            let dx = cos(angle + jitter) * distance
            let dy = sin(angle + jitter) * distance
            let fly = SKAction.moveBy(x: dx, y: dy, duration: GameControllerConfig.particleAnimDuration)
            fly.timingMode = .easeOut
            let shrink = SKAction.scale(to: GameControllerConfig.particleShrinkScale, duration: GameControllerConfig.particleAnimDuration)
            let fade = SKAction.fadeOut(withDuration: GameControllerConfig.particleAnimDuration)
            let group = SKAction.group([fly, shrink, fade])
            let remove = SKAction.removeFromParent()
            shard.run(SKAction.sequence([group, remove]))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard let controller, !isPaused else { return }
        let newSpeed: CGFloat
        switch controller.remainingPlayTime {
        case ...GameControllerConfig.speedThresholdLow:  newSpeed = GameControllerConfig.speedFast
        case ...GameControllerConfig.speedThresholdMid:  newSpeed = GameControllerConfig.speedMedium
        case ...GameControllerConfig.speedThresholdHigh:  newSpeed = GameControllerConfig.speedNormal
        default:     newSpeed = GameControllerConfig.speedSlow
        }
        if physicsWorld.speed != newSpeed {
            physicsWorld.speed = newSpeed
        }
        detectAndReleaseStuckBubbles()
    }
    
    private func maintainBubbleScreenBoundaries() {
        guard size.width > 0, size.height > 0 else { return }
        for node in children where node.name == PhysicsConstants.bubbleName {
            let radius = node.frame.width / PhysicsConstants.bubbleDiameterDivisor
            let clampedX = node.position.x.clamped(to: radius...(size.width - radius))
            let clampedY = node.position.y.clamped(to: radius...(size.height - radius))
            if node.position.x != clampedX || node.position.y != clampedY {
                node.position = CGPoint(x: clampedX, y: clampedY)
                nudgeStuckBubble(node)
            }
        }
    }
    
    private func detectAndReleaseStuckBubbles() {
        let stuckFrameThreshold = GameControllerConfig.stuckFrameThreshold
        let minimumMovementThreshold: CGFloat = GameControllerConfig.minimumMovementThreshold
        for node in children where node.name == PhysicsConstants.bubbleName {
            let currentPosition = node.position
            if let lastKnownPosition = lastKnownBubblePositions[node] {
                let hasMoved = abs(currentPosition.x - lastKnownPosition.x) >= minimumMovementThreshold
                        || abs(currentPosition.y - lastKnownPosition.y) >= minimumMovementThreshold
                if hasMoved {
                    stuckBubbleFrameCounts[node] = GameControllerConfig.resetFrameCount
                } else {
                    stuckBubbleFrameCounts[node, default: GameControllerConfig.resetFrameCount] += 1
                    if stuckBubbleFrameCounts[node, default: GameControllerConfig.resetFrameCount] >= stuckFrameThreshold {
                        nudgeStuckBubble(node)
                        stuckBubbleFrameCounts[node] = GameControllerConfig.resetFrameCount
                    }
                }
            }
            lastKnownBubblePositions[node] = currentPosition
        }
        let activeBubble = Set(children.filter {
            $0.name == PhysicsConstants.bubbleName
        })
        lastKnownBubblePositions = lastKnownBubblePositions.filter {
            activeBubble.contains($0.key)
        }
        stuckBubbleFrameCounts = stuckBubbleFrameCounts.filter {
            activeBubble.contains($0.key)
        }
    }
    
    /// - Parameters:
    ///   - node: The stuck bubble node to nudge back into play
    private func nudgeStuckBubble(_ node: SKNode) {
        guard let physicsBody = node.physicsBody else {
            return
        }
        let edgeMargin: CGFloat = GameControllerConfig.edgeMargin
        var horizontalDirection: CGFloat = CGFloat.random(in: GameControllerConfig.nudgeDirectionRange)
        var verticalDirection: CGFloat = CGFloat.random(in: GameControllerConfig.nudgeDirectionRange)
        
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
        let magnitude = sqrt(horizontalDirection * horizontalDirection + verticalDirection * verticalDirection)
        if magnitude > GameControllerConfig.minimumMagnitude {
            horizontalDirection /= magnitude
            verticalDirection /= magnitude
        }
        let impulseStrength: CGFloat = physicsBody.mass * GameControllerConfig.impulseStrengthMultiplier
        physicsBody.velocity = CGVector(
            dx: horizontalDirection * impulseStrength,
            dy: verticalDirection * impulseStrength
        )
    }
    
    func prepareToRestartSession() {
        self.removeAllChildren()
        self.removeAllActions()
        lastKnownBubblePositions.removeAll()
        stuckBubbleFrameCounts.removeAll()
        lastPoppedBubbleColor = nil
        consecutiveComboCount = GameControllerConfig.initialComboCount
        self.isPaused = false
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
        setupPhysics()
    }
    
    func restartGameSession() {
        self.removeAllChildren()
        self.removeAllActions()
        lastKnownBubblePositions.removeAll()
        stuckBubbleFrameCounts.removeAll()
        lastPoppedBubbleColor = nil
        consecutiveComboCount = GameControllerConfig.initialComboCount
        self.isPaused = false
        self.physicsWorld.speed = PhysicsConstants.physicsSpeed
        setupPhysics()
        controller?.startGame()
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
