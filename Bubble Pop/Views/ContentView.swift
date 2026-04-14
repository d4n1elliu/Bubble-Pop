//
//  ContentView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 25/3/2026.
//

import SwiftUI
import SwiftData

enum ContentUI {
    /// Padding Spacing Constants
    enum Spacing {
        static let rootVStackSpacing: CGFloat = 35
        static let labelToField: CGFloat = 12
        static let horizontalPadding: CGFloat = 70
        static let standardPadding: CGFloat = 40
        static let settingsIconSpacing: CGFloat = 8
    }
    /// Font Size Constants
    enum FontSize {
        static let titleSize: CGFloat = 48
        static let labelSize: CGFloat = 12
        static let inputNameSize: CGFloat = 18
        static let lettersTracking: CGFloat = 2
    }
    /// Button Layout Constants
    enum Layout {
        static let inputFieldHeight: CGFloat = 55
        static let inputField: CGFloat = 15
        static let cornerRadius: CGFloat = 25
        static let buttonVerticalPadding: CGFloat = 18
        
        /// Shadow Contants
        static let shadowRadius: CGFloat = 10
        static let shadowXOffset: CGFloat = 0
        static let shadowYOffset: CGFloat = 5
        static let shadowOpacity: Double = 0.3
        
        /// Background Constants
        static let fieldOpacity: Double = 0.05
    }
}

struct ContentView: View {
    @State private var playerName: String = ""
    @Environment(PlayerData.self) private var playerData
    
    @AppStorage("gameTimeframe") private var gameTimeframe = 60
    @AppStorage("maxBubbles") private var maxBubbles = 15
    
    var body: some View {
        NavigationStack {
            VStack(spacing: ContentUI.Spacing.rootVStackSpacing) {
                Spacer()
                
                /// Game title
                Text("Bubble Pop")
                    .font(.system(size: ContentUI.FontSize.titleSize, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                
                /// Enter player name inputs
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
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                }
                
                /// Start game button
                NavigationLink(destination: GameView(playerName: playerName)) {
                    Text("Start Game")
                        .font(.system(.headline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ContentUI.Layout.buttonVerticalPadding)
                        .background(playerName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .shadow(color: playerName.isEmpty ? .clear : .blue.opacity(ContentUI.Layout.shadowOpacity), radius: ContentUI.Layout.shadowRadius, x: ContentUI.Layout.shadowXOffset, y: ContentUI.Layout.shadowYOffset)
                }
                .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                //.disabled(playerName.isEmpty)
                
                /// High Score button
                NavigationLink(destination: HighScoreView()) {
                    Text("View High Scores")
                        .font(.system(.headline, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, ContentUI.Layout.buttonVerticalPadding)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, ContentUI.Spacing.horizontalPadding)
                
                Spacer()
            }
            .padding(ContentUI.Spacing.standardPadding)
            /// Navigation modifiers belong inside the stack on the main view
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView(timeframe: $gameTimeframe, bubbles: $maxBubbles)) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
/// Rendering for app preview
#Preview {
    ContentView()
        .environment(PlayerData())
        .environment(ScoreManager())
        .modelContainer(for: Item.self, inMemory: true)
}
