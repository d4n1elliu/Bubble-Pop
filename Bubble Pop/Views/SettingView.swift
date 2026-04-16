//
//  SettingView.swift
//  Bubble Pop
//
//  Created by Daniel Liu  on 14/4/2026.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("gameTimeframe") var timeframe: Int = 60
    @AppStorage("maxBubbles") var bubbles: Int = 15
    
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
                        /// Implemented a simple Double binding for the Slider
                        Slider(value: Binding(
                            get: { Double(timeframe) },
                            set: { timeframe = Int($0) }
                        ), in: 10...120, step: 10)
                        .tint(.blue)
                        .padding(.vertical, 4)
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
                        ), in: 5...30, step: 1)
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

// Fixed Preview: Since timeframe and bubbles are @AppStorage,
// they are no longer passed in the initializer.
#Preview {
    SettingsView()
}
