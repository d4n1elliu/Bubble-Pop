//
//  PhysicsConstants.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/4/2026.
//

import UIKit
import SpriteKit

enum PhysicsConstants {
    static let bubbleRadius: CGFloat = 30
    static let bubbleName = "Bubbles"
    static let bubbleBounciness: CGFloat = 1.0
    static let bubbleFriction: CGFloat = 0.0
    static let bubbleDamping: CGFloat = 0.0
    static let physicsSpeed: CGFloat = 1.0
    static let bubbleImpulseRange: ClosedRange<CGFloat> = -15.0...15.0
    static let bubbleCursorClearance: CGFloat = 100.0
    static let bubbleStrokeWidth: CGFloat = 2.5
    static let bubbleStrokeOpacity: CGFloat = 0.25
    static let bubbleStrokeWhite: CGFloat = 0.0
    static let spawnMaxAttempts: Int = 50
}
