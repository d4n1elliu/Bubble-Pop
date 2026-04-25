//
//  CountdownView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct CountdownOverlayView: View {
    @State private var remainingCountdownSeconds = CountdownUI.initialCount
    @State private var isCountdownFlashing = false
    var onFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(CountdownUI.backgroundOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: CountdownUI.vStackSpacing) {
                Text("Get Ready!")
                    .font(.system(size: CountdownUI.titleFontSize, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(CountdownUI.titleShadowOpacity), radius: CountdownUI.titleShadowRadius, x: CountdownUI.titleShadowX, y: CountdownUI.titleShadowY)
                Text("\(remainingCountdownSeconds)")
                    .font(.system(size: CountdownUI.countFontSize, weight: .black, design: .rounded))
                    .fixedSize()
                    .frame(width: CountdownUI.countFrameWidth, height: CountdownUI.countFrameHeight)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [CountdownUI.gradientTopColor, CountdownUI.gradientBottomColor],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(CountdownUI.countShadowOpacity), radius: CountdownUI.countShadowRadius, x: CountdownUI.countShadowX, y: CountdownUI.countShadowY)
                    .scaleEffect(isCountdownFlashing ? CountdownUI.scaleEffectActive : CountdownUI.scaleEffectNormal)
                    .opacity(isCountdownFlashing ? CountdownUI.opacityActive : CountdownUI.opacityNormal)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: CountdownUI.springDuration), value: remainingCountdownSeconds)
                
                VStack(spacing: CountdownUI.pointRowHSpacing) {
                    Text("Pop bubbles to earn points!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(CountdownUI.flashHintShadowOpacity), radius: CountdownUI.flashHintShadowRadius)
                    VStack(spacing: CountdownUI.pointRowVSpacing) {
                        pointRow(label: "Red",   points: "1 point",   color: CountdownUI.redBubbleColor)
                        pointRow(label: "Pink",  points: "2 points",  color: CountdownUI.pinkBubbleColor)
                        pointRow(label: "Green", points: "5 points",  color: CountdownUI.greenBubbleColor)
                        pointRow(label: "Blue",  points: "8 points",  color: CountdownUI.blueBubbleColor)
                        pointRow(label: "Black", points: "10 points", color: CountdownUI.blackBubbleColor)
                    }
                    .padding(.vertical, CountdownUI.pointRowVerticalPadding)
                    .padding(.horizontal, CountdownUI.pointRowHorizontalPadding)
                    .background(Color.white.opacity(CountdownUI.rowBackgroundOpacity), in: RoundedRectangle(cornerRadius: CountdownUI.pointRowCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: CountdownUI.pointRowCornerRadius)
                            .stroke(Color.white.opacity(CountdownUI.rowBorderOpacity), lineWidth: CountdownUI.pointRowBorderWidth)
                    )
                }
                .padding(.top, CountdownUI.topPadding)
            }
            .padding(CountdownUI.outerPadding)
        }
        .onAppear {
            remainingCountdownSeconds = CountdownUI.initialCount
            isCountdownFlashing = false
            withAnimation(.easeInOut(duration: CountdownUI.flashDuration).repeatForever(autoreverses: true)) {
                isCountdownFlashing = true
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        guard remainingCountdownSeconds > CountdownUI.countdownStopThreshold else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + CountdownUI.countdownInterval) {
            if remainingCountdownSeconds > CountdownUI.countdownNextThreshold {
                withAnimation { remainingCountdownSeconds -= 1 }
                startCountdown()
            } else {
                onFinished()
            }
        }
    }
    /// - Parameters:
    ///   - label: The bubble colour name to display
    ///   - points: The point value string to display
    ///   - color: The colour to apply to the label tex
    private func pointRow(label: String, points: String, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(color)
                .shadow(color: .black.opacity(CountdownUI.labelShadowOpacity), radius: CountdownUI.labelShadowRadius, x: CountdownUI.labelShadowX, y: CountdownUI.labelShadowY)
            Spacer()
            Text(points)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(CountdownUI.pointsShadowOpacity), radius: CountdownUI.pointsShadowRadius)
        }
        .font(.subheadline.bold())
    }
}
