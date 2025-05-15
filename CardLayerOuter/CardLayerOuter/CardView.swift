//
//  CardView.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/21/25.
//

import SwiftUI

struct CardView: View {
    let card: Card
    let styleIcon: String // SF Symbol name
    let styleColor: Color
    @State private var cardImage: NSImage?
    
    init(card: Card, styleIcon: String, styleColor: Color) {
        self.card = card
        self.styleIcon = styleIcon
        self.styleColor = styleColor
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header with icon and title
            HStack {
                Circle()
                    .fill(styleColor.muted())
                    .strokeBorder()
                    .overlay {
                        Image(systemName: styleIcon)
                            .font(.system(size: 20))
                            .foregroundColor(styleColor)
                            .shadow(color: .black, radius: 2)
                    }
                    .frame(width: 36, height: 36)
                
                Text(card.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(styleColor)
                
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            // In your CardView struct:
            if let image = cardImage {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(8)
                    .border(Color.white, width: 2)
                    .shadow(radius: 2)
            } else {
                // Your existing placeholder
                ZStack {
                    Rectangle()
                        .fill(styleColor.opacity(0.1))
                        .aspectRatio(1, contentMode: .fit)
                    
                    VStack {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(styleColor.opacity(0.3))
                        
                        Text("\(card.name) Image")
                            .font(.caption)
                            .foregroundColor(styleColor.opacity(0.5))
                    }
                }
                .cornerRadius(8)
            }
            
            // Card metadata
            metadataView
                .padding(4)
                .background(.black.opacity(0.4))
            
            // Card effects and text
            VStack(alignment: .leading, spacing: 12) {
                // Effect
                VStack(alignment: .leading, spacing: 4) {
                    Text("EFFECT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(styleColor)
                    
                    Text(card.effect)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Master Effect if exists
                if let masterEffect = card.masterEffect {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("MASTER EFFECT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(styleColor)
                        
                        Text(masterEffect)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // Drawback if exists
                if let drawback = card.drawback {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("DRAWBACK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                        
                        Text(drawback)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // Flavor text
                VStack(alignment: .leading, spacing: 4) {
                    Text(card.flavorText)
                        .font(.caption)
                        .italic()
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4)
                }
            }
            .padding(4)
            .background(.black.opacity(0.4))
            .padding(.horizontal)
            
            HStack {
                Spacer()
                Text(card.id)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background {
            Image("Background")
                .resizable()
                .overlay(.black.opacity(0.6))
                .blur(radius: 6)
        }
//        .background(Color.gray)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(styleColor.opacity(0.8), lineWidth: 12)
        )
        .frame(width: 375, height: 525)
        .onAppear {
            loadCardImage()
        }
    }
    
    struct MetadataComponentView: View {
        var title: String
        var text: String
        
        var body: some View {
            VStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(text)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
    }
    
    var metadataView: some View {
        HStack(spacing: 16) {
            MetadataComponentView(title: "Type", text: card.type.rawValue)
            Divider()
                .frame(maxHeight: 28)
            MetadataComponentView(title: "Cost", text: "\(card.cost)")
            Divider()
                .frame(maxHeight: 28)
            MetadataComponentView(title: "Die", text: card.focusDie.rawValue)
            Divider()
                .frame(maxHeight: 28)
            if let stanceType = card.stanceType {
                MetadataComponentView(title: "Stance", text: stanceType.rawValue)
                Divider()
                    .frame(maxHeight: 28)
            }
            MetadataComponentView(title: "Range", text: card.rangeRestriction.rawValue)
        }
    }
    
    private func loadCardImage() {
        if let imagesPath = AppSettings.shared.cardImagesPath {
            cardImage = CardDataService.shared.loadImage(named: card.id, from: imagesPath)
        }
    }
}

// Helper to create card preview with appropriate style colors
struct CardPreviewView: View {
    var body: some View {
        // For Blood Magic card
        CardView(
            card: Card.mockLegacyCard(),
            styleIcon: "drop.fill",
            styleColor: .red
        )
        
        // For Battle Axe card
        CardView(
            card: Card.mockAttackCard(),
            styleIcon: "shield.fill",
            styleColor: Color(red: 0.6, green: 0.4, blue: 0.2) // Brown
        )
        
        // For Longsword card
        CardView(
            card: Card.mockCard(),
            styleIcon: "bolt.horizontal.fill",
            styleColor: .blue
        )
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardPreviewView()
    }
}
