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
    
    /// Timer pulish  every second on the main thread
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            /// Semi transparent background
            Color.black.opacity(0.15)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Get Ready!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                /// Animated Countdown Number
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
                /// Hiding panel showing bubble point values
                VStack(spacing: 8) {
                    Text("Hint: Pop the bubbles to earn points!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Group {
                        Text("Red: 1").foregroundColor(.red)
                        Text("Pink: 2").foregroundColor(.red)
                        Text("Green: 5").foregroundColor(.red)
                        Text("Blue: 8").foregroundColor(.red)
                        Text("Black: 10").foregroundColor(.red)
                    }
                    .font(.subheadline.bold())
                }
                .padding(.top, 40)
            }
        }
        ///Decrementing counter each second; cancel timer and notify when done
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
