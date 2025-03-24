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
    @State private var selectedStyleName: String? = nil
    
    var body: some View {
        NavigationSplitView {
            // Sidebar content
            VStack {
                if isLoading {
                    ProgressView("Loading data...")
                } else if let error = errorMessage {
                    ContentUnavailableView(
                        "Oops, something went wrong!",
                        image: "exclamationmark.triangle.fill",
                        description: Text(String(describing: error))
                    )
                } else if fightingStyles.isEmpty {
                    ContentUnavailableView(
                        "No fighting styles to show!",
                        image: "square.dotted"
                    )
                } else {
                    List(selection: $selectedStyleName) {
                        ForEach(Array(fightingStyles.keys).sorted(), id: \.self) { styleName in
                            if let style = fightingStyles[styleName] {
                                HStack {
                                    Image(systemName: style.sfSymbol)
                                        .foregroundColor(style.accentColor)
                                    Text(style.styleName)
                                }
                                .tag(styleName)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Fighting Styles")
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        } detail: {
            if let selectedName = selectedStyleName, let selectedStyle = fightingStyles[selectedName] {
                FightingStyleDetailView(style: selectedStyle)
            } else {
                Text("Select a fighting style to view its cards")
                    .font(.title2)
                    .foregroundColor(.secondary)
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
