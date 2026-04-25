//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var playerName: String = ""
    @Environment(PlayerData.self) private var playerData
    
    @AppStorage("gameTimeframe") private var gameTimeframe = GameControllerConfig.initialPlayTime
    @AppStorage("maxBubbles") private var maxBubbles = GameControllerConfig.maxBubbles
    
    private var isNameValid: Bool {
        !playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                mainBackground
                VStack(spacing: ContentUI.Spacing.rootVStackSpacing) {
                    Spacer().frame(height: ContentUI.Layout.spacerHeight)
                
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
                        .lineLimit(ContentUI.Layout.titleLineLimit)
                    
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
                        HStack(spacing: ContentUI.Layout.hStackSpacing) {
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
                            : LinearGradient(colors: [.gray.opacity(ContentUI.Layout.grayButtonOpacity), .gray.opacity(ContentUI.Layout.grayButtonOpacity)], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: ContentUI.Layout.buttonCornerRadius))
                        .shadow(
                            color: isNameValid ? .blue.opacity(ContentUI.Layout.buttonShadowOpacity) : .clear,
                            radius: ContentUI.Layout.shadowRadius,
                            y: ContentUI.Layout.shadowYOffset
                        )
                    }
                    .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                    .disabled(!isNameValid)
                    
                    NavigationLink(destination: HighScoreView()) {
                        HStack(spacing: ContentUI.Layout.hStackSpacing) {
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
                        .clipShape(RoundedRectangle(cornerRadius: ContentUI.Layout.buttonCornerRadius))
                        .shadow(
                            color: .orange.opacity(ContentUI.Layout.buttonShadowOpacity),
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
                                .font(.system(size: ContentUI.Layout.settingsIconSize, weight: .semibold))
                                .padding(ContentUI.Layout.settingsIconPadding)
                        }
                    }
                }
            }
        }
    }
    private var mainBackground: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(ContentUI.Layout.bgBlueOpacity))
                .frame(width: ContentUI.Layout.bgCircleLargeSize, height: ContentUI.Layout.bgCircleLargeSize)
                .blur(radius: ContentUI.Layout.bgBlurLarge)
                .offset(x: ContentUI.Layout.bgLargeOffsetX, y: ContentUI.Layout.bgLargeOffsetY)
            
            Circle()
                .fill(Color.purple.opacity(ContentUI.Layout.bgPurpleOpacity))
                .frame(width: ContentUI.Layout.bgCircleMediumSize, height: ContentUI.Layout.bgCircleMediumSize)
                .blur(radius: ContentUI.Layout.bgBlurMedium)
                .offset(x: ContentUI.Layout.bgMediumOffsetX, y: ContentUI.Layout.bgMediumOffsetY)
            
            Circle()
                .fill(Color.pink.opacity(ContentUI.Layout.bgPinkOpacity))
                .frame(width: ContentUI.Layout.bgCircleSmallSize, height: ContentUI.Layout.bgCircleSmallSize)
                .blur(radius: ContentUI.Layout.bgBlurSmall)
                .offset(x: ContentUI.Layout.bgSmallOffsetX, y: ContentUI.Layout.bgSmallOffsetY)
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
