//
//  Color+CardLayerOuter.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 5/13/25.
//

import SwiftUI
import AppKit

extension Color {
    // Convert SwiftUI Color to NSColor
    private func toNSColor() -> NSColor {
        let cgColor = NSColor(self).cgColor
        return NSColor(cgColor: cgColor) ?? NSColor.black
    }
    
    // Create SwiftUI Color from NSColor
    private static func fromNSColor(_ nsColor: NSColor) -> Color {
        return Color(nsColor: nsColor)
    }
    
    // Get HSB components
    private func hsb() -> (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        let nsColor = self.toNSColor().usingColorSpace(.sRGB) ?? NSColor.black
        return (nsColor.hueComponent, nsColor.saturationComponent, nsColor.brightnessComponent, nsColor.alphaComponent)
    }
    
    // Complementary color (opposite on color wheel)
    func complementary() -> Color {
        let hsb = self.hsb()
        let nsColor = NSColor(hue: (hsb.hue + 0.5).truncatingRemainder(dividingBy: 1.0),
                             saturation: hsb.saturation,
                             brightness: hsb.brightness,
                             alpha: hsb.alpha)
        return Color(nsColor: nsColor)
    }
    
    // Analogous colors (adjacent on color wheel)
    func analogous(degrees: CGFloat = 30) -> (Color, Color) {
        let hsb = self.hsb()
        let angle = degrees / 360
        
        let nsColor1 = NSColor(hue: (hsb.hue - angle).truncatingRemainder(dividingBy: 1.0),
                              saturation: hsb.saturation,
                              brightness: hsb.brightness,
                              alpha: hsb.alpha)
        
        let nsColor2 = NSColor(hue: (hsb.hue + angle).truncatingRemainder(dividingBy: 1.0),
                              saturation: hsb.saturation,
                              brightness: hsb.brightness,
                              alpha: hsb.alpha)
        
        return (Color(nsColor: nsColor1), Color(nsColor: nsColor2))
    }
    
    // Triadic colors (evenly spaced on color wheel)
    func triadic() -> (Color, Color) {
        let hsb = self.hsb()
        
        let nsColor1 = NSColor(hue: (hsb.hue + 1.0/3).truncatingRemainder(dividingBy: 1.0),
                              saturation: hsb.saturation,
                              brightness: hsb.brightness,
                              alpha: hsb.alpha)
        
        let nsColor2 = NSColor(hue: (hsb.hue + 2.0/3).truncatingRemainder(dividingBy: 1.0),
                              saturation: hsb.saturation,
                              brightness: hsb.brightness,
                              alpha: hsb.alpha)
        
        return (Color(nsColor: nsColor1), Color(nsColor: nsColor2))
    }
    
    // Muted version (same hue, lower saturation)
    func muted(factor: CGFloat = 0.5) -> Color {
        let hsb = self.hsb()
        let nsColor = NSColor(hue: hsb.hue,
                             saturation: hsb.saturation * factor,
                             brightness: hsb.brightness,
                             alpha: hsb.alpha)
        return Color(nsColor: nsColor)
    }
    
    // Monochromatic (same hue, different brightness)
    func monochromatic(darker: CGFloat = 0.3, lighter: CGFloat = 0.3) -> (Color, Color) {
        let hsb = self.hsb()
        
        let nsColorDarker = NSColor(hue: hsb.hue,
                                   saturation: hsb.saturation,
                                   brightness: max(hsb.brightness - darker, 0),
                                   alpha: hsb.alpha)
        
        let nsColorLighter = NSColor(hue: hsb.hue,
                                    saturation: hsb.saturation,
                                    brightness: min(hsb.brightness + lighter, 1),
                                    alpha: hsb.alpha)
        
        return (Color(nsColor: nsColorDarker), Color(nsColor: nsColorLighter))
    }
}
