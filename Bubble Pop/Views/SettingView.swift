//
//  SettingView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("gameTimeframe") var timeframe: Int = GameControllerConfig.initialPlayTime
    @AppStorage("maxBubbles") var bubbles: Int = GameControllerConfig.maxBubbles
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Game Time")
                            Spacer()
                            Text("\(timeframe)s")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Slider(value: Binding(
                            get: { Double(timeframe) },
                            set: { timeframe = Int($0) }
                        ), in: SettingsUI.timeframeMin...SettingsUI.timeframeMax, step: SettingsUI.timeframeStep)
                        .tint(.blue)
                        .padding(.vertical, SettingsUI.sliderVerticalPadding)
                    }
                } header: {
                    Text("Duration")
                } footer: {
                    Text("Choose how long each game session lasts (10s to 120s).")
                }
                
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Max Bubbles")
                            Spacer()
                            Text("\(bubbles)")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        Slider(value: Binding(
                            get: { Double(bubbles) },
                            set: { bubbles = Int($0) }
                        ), in: SettingsUI.bubblesMin...SettingsUI.bubblesMax, step: SettingsUI.bubblesStep)
                        .tint(.blue)
                    }
                } header: {
                    Text("Difficulty")
                } footer: {
                    Text("Sets the maximum number of bubbles displayed simultaneously (5 to 30).")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
