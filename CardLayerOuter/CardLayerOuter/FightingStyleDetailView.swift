//
//  FightingStyleDetailView.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/23/25.
//

import SwiftUI

struct FightingStyleDetailView: View {
    let style: FightingStyle
     @State private var selectedFilter: String = "All"
     
     var filteredCards: [Card] {
         if selectedFilter == "All" {
             return style.cards
         } else if selectedFilter == "Legacy" {
             return style.cards.filter { $0.isLegacy == true }
         } else {
             return style.cards.filter { $0.type.rawValue == selectedFilter }
         }
     }
     
     var body: some View {
         ScrollView {
             // Style header with metadata
             VStack(alignment: .leading, spacing: 20) {
                 // Style header
                 HStack(alignment: .top) {
                     // Icon and basic info
                     VStack(alignment: .center) {
                         Image(systemName: style.sfSymbol)
                             .font(.system(size: 80))
                             .foregroundColor(style.accentColor)
                             .frame(width: 120, height: 120)
                             .background(style.accentColor.opacity(0.1))
                             .clipShape(Circle())
                         
                         Text(style.styleType.rawValue)
                             .font(.headline)
                             .padding(.horizontal, 12)
                             .padding(.vertical, 6)
                             .background(style.accentColor.opacity(0.2))
                             .cornerRadius(12)
                         
                         Text(style.rangePreference.rawValue)
                             .font(.subheadline)
                             .padding(.horizontal, 10)
                             .padding(.vertical, 4)
                             .background(style.accentColor.opacity(0.15))
                             .cornerRadius(8)
                     }
                     .frame(width: 150)
                     .padding(.trailing, 10)
                     
                     // Description and cards count
                     VStack(alignment: .leading, spacing: 12) {
                         Text(style.styleDescription)
                             .font(.body)
                             .fixedSize(horizontal: false, vertical: true)
                         
                         if let historicalInfo = style.historicalInspiration {
                             DisclosureGroup("Historical Inspiration") {
                                 Text(historicalInfo)
                                     .font(.callout)
                                     .foregroundColor(.secondary)
                                     .fixedSize(horizontal: false, vertical: true)
                                     .padding(.vertical, 8)
                             }
                             .padding(.top, 8)
                         }
                         
                         Divider()
                             .padding(.vertical, 8)
                         
                         Text("Contains \(style.cards.count) cards")
                             .font(.headline)
                     }
                 }
                 .padding()
                 .background(style.accentColor.opacity(0.05))
                 .cornerRadius(16)
                 
                 // Divider between header and cards
                 Rectangle()
                     .frame(height: 4)
                     .foregroundColor(style.accentColor)
                     .cornerRadius(2)
                 
                 // Card category headers
                 VStack(alignment: .leading, spacing: 8) {
                     Text("Cards")
                         .font(.title2)
                         .fontWeight(.bold)
                     
                     // Filter pills with functionality
                     ScrollView(.horizontal, showsIndicators: false) {
                         HStack(spacing: 10) {
                             ForEach(["All", "Stance", "Attack", "Reaction", "Technique", "Legacy"], id: \.self) { type in
                                 Button(action: {
                                     selectedFilter = type
                                 }) {
                                     Text(type)
                                         .font(.caption)
                                         .fontWeight(.medium)
                                         .padding(.horizontal, 12)
                                         .padding(.vertical, 6)
                                         .background(
                                             selectedFilter == type ?
                                                 style.accentColor.opacity(0.6) :
                                                 style.accentColor.opacity(0.15)
                                         )
                                         .foregroundColor(
                                             selectedFilter == type ?
                                                 .white :
                                                 .primary
                                         )
                                         .cornerRadius(20)
                                 }
                                 .buttonStyle(PlainButtonStyle())
                             }
                         }
                         .padding(.bottom, 4)
                     }
                 }
                 .padding(.horizontal)
                 
                 // Filtered Cards Count
                 Text("Showing \(filteredCards.count) of \(style.cards.count) cards")
                     .font(.subheadline)
                     .foregroundColor(.secondary)
                     .padding(.horizontal)
                 
                 // Cards Grid with Filtered Cards
                 LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], spacing: 20) {
                     ForEach(filteredCards, id: \.id) { card in
                         CardView(
                             card: card,
                             styleIcon: style.sfSymbol,
                             styleColor: style.accentColor
                         )
                     }
                 }
                 .padding(.horizontal)
                 
                 // Show message if no cards match filter
                 if filteredCards.isEmpty {
                     VStack {
                         Text("No cards match the selected filter")
                             .font(.headline)
                             .foregroundColor(.secondary)
                             .padding()
                     }
                     .frame(maxWidth: .infinity)
                     .padding(.vertical, 30)
                 }
             }
             .padding(.vertical)
         }
         .navigationTitle(style.styleName)
     }
 }
