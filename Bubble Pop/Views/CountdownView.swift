//
//  CountdownView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI
import Combine

struct CountdownOverlayView: View {
    @State private var count = 3
    @State private var isFlashing = false
    var onFinished: () -> Void
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Get Ready!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("\(count)")
                    .font(.system(size: 120, weight: .black, design: .rounded))
                    .foregroundColor(.blue)
                    .scaleEffect(isFlashing ? 1.2 : 1.0)
                    .opacity(isFlashing ? 0.5 : 1.0)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                            isFlashing = true
                        }
                    }
                
                VStack(spacing: 8) {
                    Text("Hint: Pop the bubbles to earn points!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Red: 1 | Pink: 2 | Green: 5").foregroundColor(.red)
                        Text("Blue: 8 | Black: 10").foregroundColor(.red)
                    }
                    .font(.caption.bold())
                }
                .padding(.top, 40)
            }
        }
        .onReceive(timer) { _ in
            if count > 1 {
                count -= 1
            } else {
                timer.upstream.connect().cancel()
                onFinished()
            }
        }
    }
}
