//
//  CountdownView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct CountdownOverlayView: View {
    @State private var count = 3
    @State private var isFlashing = false
    var onFinished: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.50)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Get Ready!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)

                Text("\(count)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .fixedSize()
                    .frame(width: 200, height: 150)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.5, green: 0.8, blue: 1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
                    .scaleEffect(isFlashing ? 1.2 : 1.0)
                    .opacity(isFlashing ? 0.7 : 1.0)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.4), value: count)

                VStack(spacing: 8) {
                    Text("Pop bubbles to earn points!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.5), radius: 2)

                    VStack(spacing: 6) {
                        pointRow(label: "Red",   points: "1 pt",   color: Color(red: 1.0, green: 0.25, blue: 0.25))
                        pointRow(label: "Pink",  points: "2 pts",  color: Color(red: 1.0, green: 0.4,  blue: 0.65))
                        pointRow(label: "Green", points: "5 pts",  color: Color(red: 0.1, green: 0.95, blue: 0.3))
                        pointRow(label: "Blue",  points: "8 pts",  color: Color(red: 0.2, green: 0.55, blue: 1.0))
                        pointRow(label: "Black", points: "10 pts", color: Color(red: 0.75, green: 0.75, blue: 0.75))
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                }
                .padding(.top, 20)
            }
            .padding(30)
        }
        .onAppear {
            count = 3
            isFlashing = false
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isFlashing = true
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        guard count > 0 else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if count > 1 {
                withAnimation { count -= 1 }
                startCountdown()
            } else {
                onFinished()
            }
        }
    }

    private func pointRow(label: String, points: String, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundColor(color)
                .shadow(color: .black.opacity(0.8), radius: 3, x: 0, y: 1)
            Spacer()
            Text(points)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2)
        }
        .font(.subheadline.bold())
    }
}
