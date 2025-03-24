//
//  FightingStyleView.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/23/25.
//

import SwiftUI

struct FightingStyleView: View {
    let style: FightingStyle
    
    var body: some View {
        VStack {
            Image(systemName: style.sfSymbol)
                .font(.system(size: 60))
                .foregroundColor(style.accentColor)
                .padding()
                .frame(width: 100, height: 100)
                .background(style.accentColor.opacity(0.1))
                .clipShape(Circle())
            
            Text(style.styleName)
                .font(.headline)
                .foregroundColor(style.accentColor)
            
            Text("\(style.cards.count) Cards")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            Text(style.rangePreference.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(style.accentColor.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .frame(width: 200, height: 200)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(style.accentColor.opacity(0.5), lineWidth: 2)
        )
    }
}
