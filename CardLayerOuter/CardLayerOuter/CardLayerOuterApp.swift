//
//  CardLayerOuterApp.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/21/25.
//

import SwiftUI

@main
struct CardLayerOuterApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 900, minHeight: 600)
                .navigationViewStyle(DoubleColumnNavigationViewStyle())
        }
    }
}
