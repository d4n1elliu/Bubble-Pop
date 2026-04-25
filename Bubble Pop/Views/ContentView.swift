//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

enum ContentUI {
    enum Spacing {
        static let rootVStackSpacing: CGFloat = 35
        static let labelToField: CGFloat = 12
        static let horizontalPadding: CGFloat = 70
        static let standardPadding: CGFloat = 40
        static let settingsIconSpacing: CGFloat = 8
    }
    enum FontSize {
        static let titleSize: CGFloat = 80
        static let labelSize: CGFloat = 12
        static let inputNameSize: CGFloat = 18
        static let lettersTracking: CGFloat = 2
    }
    enum Layout {
        static let inputFieldHeight: CGFloat = 55
        static let inputField: CGFloat = 15
        static let cornerRadius: CGFloat = 25
        static let buttonVerticalPadding: CGFloat = 18
        static let spacerHeight: CGFloat = 5
        static let settingsIconSize: CGFloat = 18
        static let settingsIconPadding: CGFloat = 10
        static let buttonCornerRadius: CGFloat = 16
        static let hStackSpacing: CGFloat = 8
        static let shadowRadius: CGFloat = 10
        static let shadowXOffset: CGFloat = 0
        static let shadowYOffset: CGFloat = 5
        static let shadowOpacity: Double = 0.3
        
        static let fieldOpacity: Double = 0.05
    }
}

struct ContentView: View {
    @State private var playerName: String = ""
    @Environment(PlayerData.self) private var playerData
    
    @AppStorage("gameTimeframe") private var gameTimeframe = 60
    @AppStorage("maxBubbles") private var maxBubbles = 15
    
    private var isNameValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                bubbleBackground
                VStack(spacing: ContentUI.Spacing.rootVStackSpacing) {
                    Spacer().frame(height: 5)
                
                    Text("Bubble Pop")
                        .font(.system(size: ContentUI.FontSize.titleSize, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .green],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    VStack(spacing: ContentUI.Spacing.labelToField) {
                        Text("PLAYER NAME")
                            .font(.system(size: ContentUI.FontSize.labelSize, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                            .tracking(ContentUI.FontSize.lettersTracking)
                        
                        TextField("Enter your name", text: $playerName)
                            .font(.system(size: ContentUI.FontSize.inputNameSize, weight: .medium, design: .rounded))
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(height: ContentUI.Layout.inputFieldHeight)
                            .background(Color.black.opacity(ContentUI.Layout.fieldOpacity), in: RoundedRectangle(cornerRadius: ContentUI.Layout.inputField))
                            .autocorrectionDisabled(true)
                            .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                    }
                    
                    NavigationLink(destination: GameView(playerName: playerName)) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Start Game")
                        }
                        .font(.system(.headline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ContentUI.Layout.buttonVerticalPadding)
                        .foregroundColor(.white)
                        .background(
                            isNameValid
                            ? LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(
                            color: isNameValid ? .blue.opacity(0.4) : .clear,
                            radius: ContentUI.Layout.shadowRadius,
                            y: ContentUI.Layout.shadowYOffset
                        )
                    }
                    .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                    .disabled(!isNameValid)
                    
                    NavigationLink(destination: HighScoreView()) {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                            Text("View High Scores")
                        }
                        .font(.system(.headline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ContentUI.Layout.buttonVerticalPadding)
                        .foregroundColor(.white)
                        .background(
                            LinearGradient(
                                colors: [.blue, .green,],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(
                            color: .orange.opacity(0.4),
                            radius: ContentUI.Layout.shadowRadius,
                            y: ContentUI.Layout.shadowYOffset
                        )
                    }
                    .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                    
                    Spacer()
                }
                .padding(ContentUI.Spacing.standardPadding)
                .toolbar(.visible, for: .navigationBar)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(10)
                        }
                    }
                }
            }
        }
    }
    private var bubbleBackground: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.25))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -120, y: -300)
            
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: 130, y: -100)
            
            Circle()
                .fill(Color.pink.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: -80, y: 300)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
        .environment(PlayerData())
        .environment(ScoreManager())
        .modelContainer(for: Item.self, inMemory: true)
}
