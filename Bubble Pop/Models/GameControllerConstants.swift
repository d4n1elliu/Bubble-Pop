//
//  GameControllerConstants.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/4/2026.
//

import UIKit
import SpriteKit

enum GameControllerConfig {
    static let initialPlayTime: Int = 60
    static let maxBubbles: Int = 15
    static let timerInterval: TimeInterval = 1.0
    static let initialScore: Int = 0
    static let initialSpawnCount: Int = 0
    static let physicsCleanupDelay: Double = 0.15
    static let bubbleNodeName = "Bubbles"
    static let unknownPlayerName: String = "Unknown"
    static let comboMultiplier: Double = 1.5
    static let initialSpawnDelay: Double = 0.2
    static let bubbleFadeInDuration: Double = 0.3
    static let bubbleFadeOutDuration: Double = 0.25
    static let minBubbleRemoval: Int = 1
    static let maxBubbleRemoval: Int = 3
    static let speedFast: CGFloat = 5.0
    static let speedMedium: CGFloat = 3.5
    static let speedNormal: CGFloat = 2.0
    static let speedSlow: CGFloat = 1.0
    static let speedThresholdLow: Int = 10
    static let speedThresholdMid: Int = 30
    static let speedThresholdHigh: Int = 60
    static let stuckFrameThreshold: Int = 3
    static let minimumMovementThreshold: CGFloat = 0.5
    static let edgeMargin: CGFloat = 40
    static let impulseStrengthMultiplier: CGFloat = 80
    static let particleCount: Int = 10
    static let particleRadiusRatio: CGFloat = 0.18
    static let particleMinDistance: CGFloat = 1.2
    static let particleMaxDistance: CGFloat = 2.2
    static let particleJitterRange: CGFloat = 0.3
    static let particleAnimDuration: CGFloat = 0.35
    static let particleShrinkScale: CGFloat = 0.1
    static let popScaleTo: CGFloat = 1.3
    static let popScaleDuration: Double = 0.08
    static let popFadeDuration: Double = 0.12
    static let comboLabelFontSize: CGFloat = 28
    static let comboLabelMoveX: CGFloat = 0
    static let comboLabelMoveY: CGFloat = 60
    static let comboLabelAnimDuration: Double = 0.6
    static let comboMinCount: Int = 2
    static let popSoundFile: String = "bubblepop_sound.mp3"
    static let comboSoundFile: String = "1.5x_combo_sound.mp3"
    static let comboLabelFont: String = "AvenirNext-Bold"
    static let comboLabelZPosition: CGFloat = 10
    static let particleZPosition: CGFloat = 5
    static let particleInitialAlpha: CGFloat = 1.0
    static let nudgeDirectionRange: ClosedRange<CGFloat> = -1.0...1.0
    static let fullCircleRadians: CGFloat = .pi * 2
    static let initialComboCount: Int = 0
    static let firstComboCount: Int = 1
    static let resetFrameCount: Int = 0
    static let minimumMagnitude: CGFloat = 0
    static let bubbleInitialAlpha: CGFloat = 0
    static let gameOverThreshold: Int = 0
}
