//
//  Card.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/21/25.
//

import Foundation
import SwiftUI

struct Card: Codable {
    // Core properties
    let id: String
    let name: String
    let subtitle: String?
    let type: CardType
    let stanceType: StanceType?
    let cost: Int
    let focusDie: FocusDie
    let effect: String
    let masterEffect: String?
    let flavorText: String
    let rangeRestriction: RangeRestriction
    
    // Legacy card properties
    let drawback: String?
    let isLegacy: Bool?
    
    // Optional metadata
    let historicalInspiration: String?
    
    enum CardType: String, Codable {
        case stance = "Stance"
        case attack = "Attack"
        case reaction = "Reaction"
        case technique = "Technique"
    }
    
    enum StanceType: String, Codable {
        case aggressive = "Aggressive"
        case defensive = "Defensive"
        case evasive = "Evasive"
    }
    
    enum FocusDie: String, Codable {
        case d4 = "d4"
        case d6 = "d6"
        case d8 = "d8"
        case d10 = "d10"
        case d12 = "d12"
        
        var sides: Int {
            switch self {
            case .d4: return 4
            case .d6: return 6
            case .d8: return 8
            case .d10: return 10
            case .d12: return 12
            }
        }
        
        var averageValue: Double {
            return Double(sides + 1) / 2.0
        }
    }
    
    enum RangeRestriction: String, Codable {
        case any = "Any"
        case closeRangeOnly = "Close Range Only"
        case farRangeOnly = "Far Range Only"
        case farRangePreferred = "Far Range preferred"
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            
            switch rawValue {
            case "Any": self = .any
            case "Close Range Only", "Close Range only": self = .closeRangeOnly
            case "Far Range Only", "Far Range Only (unless modified)": self = .farRangeOnly
            case "Far Range preferred", "Far Range Preferred": self = .farRangePreferred
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid RangeRestriction: \(rawValue)"
                )
            }
        }
    }
    
    // For handling potentially missing fields
    enum CodingKeys: String, CodingKey {
        case id, name, subtitle, type, stanceType, cost, focusDie, effect
        case masterEffect, flavorText, rangeRestriction, drawback, isLegacy
        case historicalInspiration
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        type = try container.decode(CardType.self, forKey: .type)
        stanceType = try container.decodeIfPresent(StanceType.self, forKey: .stanceType)
        cost = try container.decode(Int.self, forKey: .cost)
        focusDie = try container.decode(FocusDie.self, forKey: .focusDie)
        effect = try container.decode(String.self, forKey: .effect)
        masterEffect = try container.decodeIfPresent(String.self, forKey: .masterEffect)
        flavorText = try container.decode(String.self, forKey: .flavorText)
        rangeRestriction = try container.decode(RangeRestriction.self, forKey: .rangeRestriction)
        drawback = try container.decodeIfPresent(String.self, forKey: .drawback)
        isLegacy = try container.decodeIfPresent(Bool.self, forKey: .isLegacy)
        historicalInspiration = try container.decodeIfPresent(String.self, forKey: .historicalInspiration)
    }
    
    // Manual initializer for creating cards without decoding
    init(
        id: String,
        name: String,
        subtitle: String? = nil,
        type: CardType,
        stanceType: StanceType? = nil,
        cost: Int,
        focusDie: FocusDie,
        effect: String,
        masterEffect: String? = nil,
        flavorText: String,
        rangeRestriction: RangeRestriction,
        drawback: String? = nil,
        isLegacy: Bool? = nil,
        historicalInspiration: String? = nil
    ) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.type = type
        self.stanceType = stanceType
        self.cost = cost
        self.focusDie = focusDie
        self.effect = effect
        self.masterEffect = masterEffect
        self.flavorText = flavorText
        self.rangeRestriction = rangeRestriction
        self.drawback = drawback
        self.isLegacy = isLegacy
        self.historicalInspiration = historicalInspiration
    }
    
    // Static factory method to create a mock card
    static func mockCard() -> Card {
        return Card(
            id: "LS-01",
            name: "Vom Tag",
            subtitle: "From the Roof",
            type: .stance,
            stanceType: .aggressive,
            cost: 2,
            focusDie: .d8,
            effect: "Enter the Vom Tag stance. While in this stance, your attacks deal +1 damage.",
            masterEffect: "If you've played 2+ Longsword cards this turn, also draw 1 card when you deal damage.",
            flavorText: "The swordsman holds the blade high overhead, muscles coiled like a spring, ready to deliver crushing overhead blows.",
            rangeRestriction: .any
        )
    }
    
    // Create a sample legacy card
    static func mockLegacyCard() -> Card {
        return Card(
            id: "BM-L1",
            name: "Ancestral Sacrifice",
            subtitle: "Legacy Attack",
            type: .attack,
            stanceType: nil,
            cost: 3,
            focusDie: .d12,
            effect: "Lose 3 health. Deal 5 damage that cannot be reduced by defensive effects. Gain Vitality equal to the damage dealt.",
            masterEffect: nil,
            flavorText: "The blood rite passed down through your lineage draws upon primal forces that even the most accomplished mages fear to touch, its power matched only by its terrible cost.",
            rangeRestriction: .any,
            drawback: "You cannot heal or gain health from any source until the end of your next turn.",
            isLegacy: true,
            historicalInspiration: nil
        )
    }
    
    // Create a sample attack card
    static func mockAttackCard() -> Card {
        return Card(
            id: "BA-04",
            name: "Brotna",
            subtitle: "Sunder Strike",
            type: .attack,
            cost: 3,
            focusDie: .d12,
            effect: "Deal 2 damage. You may spend up to 3 Momentum to add that much additional damage. Lose all Momentum after this effect resolves.",
            masterEffect: "If you've played 2+ Battle Axe cards this turn, this attack also forces your opponent to discard a Focus card.",
            flavorText: "The axe-wielder channels accumulated force into a single devastating overhead chop capable of splitting shields and crushing armor with sheer power.",
            rangeRestriction: .closeRangeOnly,
            historicalInspiration: "From Old Norse 'brotna' meaning 'to break'. Based on archaeological evidence of shield damage patterns and saga accounts of axes breaking through shields and armor in a single powerful blow."
        )
    }
}

struct FightingStyle: Codable {
    let styleName: String
    let styleDescription: String
    let styleType: StyleType
    let rangePreference: RangePreference
    let historicalInspiration: String?
    let sfSymbol: String
    let color: ColorComponents
    let cards: [Card]
    
    struct ColorComponents: Codable {
        let red: Double
        let green: Double
        let blue: Double
        
        var swiftUIColor: Color {
            Color(red: red, green: green, blue: blue)
        }
    }
    
    enum StyleType: String, Codable {
        case martial = "Martial"
        case magical = "Magical"
    }
    
    enum RangePreference: String, Codable {
        case closeRange = "Close Range"
        case farRange = "Far Range"
        case flexibleRange = "Flexible Range"
    }
    
    // Helper computed property to get the Color
    var accentColor: Color {
        return color.swiftUIColor
    }
    
    // Static factory method to create a mock fighting style
    static func mockFightingStyle() -> FightingStyle {
        return FightingStyle(
            styleName: "Longsword",
            styleDescription: "A balanced fighting style based on historical German longsword techniques, featuring tactical stance-switching and powerful strikes.",
            styleType: .martial,
            rangePreference: .closeRange,
            historicalInspiration: "Based on the German school of swordsmanship from the 14th-16th centuries.",
            sfSymbol: "bolt.horizontal.fill",
            color: ColorComponents(red: 0.0, green: 0.0, blue: 0.8),
            cards: [.mockAttackCard(), .mockCard(), .mockLegacyCard()]
        )
    }
}
