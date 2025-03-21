//
//  MainView.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/21/25.
//

import SwiftUI
import Foundation

struct MainView: View {
    @State private var fightingStyles: [String: FightingStyle] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showSettings = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading data...")
            } else if let error = errorMessage {
                VStack {
                    Text("Error loading data")
                        .font(.headline)
                    Text(error)
                        .foregroundColor(.red)
                    Button("Open Settings") {
                        showSettings = true
                    }
                    .padding()
                }
            } else if fightingStyles.isEmpty {
                VStack {
                    Text("No data loaded")
                        .font(.headline)
                    Button("Open Settings") {
                        showSettings = true
                    }
                    .padding()
                    Button("Load Data") {
                        loadData()
                    }
                    .padding()
                    .disabled(AppSettings.shared.jsonDataPath == nil)
                }
            } else {
                // Your card browsing UI here
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], spacing: 20) {
                        ForEach(Array(fightingStyles.keys), id: \.self) { styleName in
                            if let style = fightingStyles[styleName], !style.cards.isEmpty {
                                CardView(
                                    card: style.cards[0],
                                    styleIcon: style.sfSymbol,
                                    styleColor: style.accentColor
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .onDisappear {
                    loadData()
                }
        }
        .onAppear {
            loadData()
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    showSettings = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
    }
    
    private func loadData() {
        guard let jsonPath = AppSettings.shared.jsonDataPath else {
            errorMessage = "JSON data path not set. Please go to settings."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            let styles = CardDataService.shared.loadFightingStyles(from: jsonPath)
            
            DispatchQueue.main.async {
                isLoading = false
                if let styles = styles {
                    fightingStyles = styles
                } else {
                    errorMessage = "Failed to parse JSON data. Please check the file format."
                }
            }
        }
    }
}
