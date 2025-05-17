import SwiftUI
import AppKit

class CardExportService {
    static let shared = CardExportService()
    
    private init() {}
    
    // Export a single card as PNG
    func exportCard(_ card: Card, styleIcon: String, styleColor: Color, toDirectory directory: URL) -> URL? {
        // Create CardView for rendering
        let cardView = CardView(card: card, styleIcon: styleIcon, styleColor: styleColor)
        
        // Create safe filename
        let safeFilename = card.id.replacingOccurrences(of: " ", with: "_")
        let fileURL = directory.appendingPathComponent("\(safeFilename).png")
        
        // Render and save the view as PNG
        do {
            if let pngData = renderViewAsPNG(cardView) {
                try pngData.write(to: fileURL)
                print("Successfully exported card: \(card.id) to \(fileURL.path)")
                return fileURL
            } else {
                print("Failed to render card \(card.id) to PNG")
                return nil
            }
        } catch {
            print("Error saving card image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Export all cards for a style
    func exportAllCardsForStyle(_ style: FightingStyle, toDirectory directory: URL, progressHandler: @escaping (Int, Int) -> Void) {
        let totalCards = style.cards.count
        
        // Process each card
        for (index, card) in style.cards.enumerated() {
            print("Exporting card \(index+1) of \(totalCards) for style \(style.styleName)")
            let _ = exportCard(card, styleIcon: style.sfSymbol, styleColor: style.accentColor, toDirectory: directory)
            // Report progress
            progressHandler(index + 1, totalCards)
        }
    }
    
    // Export all cards for all styles
    func exportAllCards(_ styles: [String: FightingStyle], toDirectory directory: URL, progressHandler: @escaping (Int, Int, String) -> Void) {
        let totalStyles = styles.count
        var currentStyleIndex = 0
        var totalExportedCards = 0
        var totalCards = 0
        
        // Count total cards
        for (_, style) in styles {
            totalCards += style.cards.count
        }
        
        print("Starting export of \(totalCards) cards from \(totalStyles) styles to \(directory.path)")
        
        // Check if destination directory is writable
        if !FileManager.default.isWritableFile(atPath: directory.path) {
            print("ERROR: Destination directory is not writable: \(directory.path)")
            return
        }
        
        // Process each style
        for (styleName, style) in styles {
            currentStyleIndex += 1
            print("Processing style \(currentStyleIndex) of \(totalStyles): \(styleName)")
            
            // Create subfolder for this style
            let styleDirectory = directory.appendingPathComponent(style.styleName, isDirectory: true)
            
            do {
                // Check if style directory already exists
                if FileManager.default.fileExists(atPath: styleDirectory.path) {
                    print("Style directory already exists: \(styleDirectory.path)")
                } else {
                    print("Creating style directory: \(styleDirectory.path)")
                    try FileManager.default.createDirectory(at: styleDirectory, withIntermediateDirectories: true)
                }
                
                print("Exporting \(style.cards.count) cards for style \(styleName)")
                
                // Export all cards for this style
                for (cardIndex, card) in style.cards.enumerated() {
                    // Provide detailed progress to help debug
                    print("Exporting card \(cardIndex+1)/\(style.cards.count) (global: \(totalExportedCards+1)/\(totalCards)): \(card.id) for style \(styleName)")
                    
                    // Call export method
                    let exportResult = exportCard(card, styleIcon: style.sfSymbol, styleColor: style.accentColor, toDirectory: styleDirectory)
                    
                    // Increment counter regardless of success (to avoid hanging)
                    totalExportedCards += 1
                    
                    // Report progress after each card
                    progressHandler(totalExportedCards, totalCards, styleName)
                }
                
            } catch {
                print("ERROR creating directory for style \(style.styleName): \(error.localizedDescription)")
            }
        }
        
        print("Export process completed - exported \(totalExportedCards) of \(totalCards) cards")
    }
    
    // Render SwiftUI view as PNG data using NSHostingView
    private func renderViewAsPNG(_ view: some View) -> Data? {
        // For debugging
        print("Starting to render view as PNG")
        
        // Create a hosting view for the SwiftUI view
        let hostingView = NSHostingView(rootView: view.frame(width: 375, height: 525))
        hostingView.frame = NSRect(x: 0, y: 0, width: 375, height: 525)
        
        // Make sure the view is laid out
        hostingView.layout()
        
        // Create a bitmap representation of the view
        let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(hostingView.bounds.width * 3), // 3x for higher resolution
            pixelsHigh: Int(hostingView.bounds.height * 3),
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .calibratedRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )
        
        if bitmap == nil {
            print("Failed to create bitmap")
            return nil
        }
        
        bitmap?.size = NSSize(width: hostingView.bounds.width * 3, height: hostingView.bounds.height * 3)
        
        // Draw the view into the bitmap
        NSGraphicsContext.saveGraphicsState()
        if let context = NSGraphicsContext(bitmapImageRep: bitmap!) {
            NSGraphicsContext.current = context
            NSGraphicsContext.current?.cgContext.scaleBy(x: 3.0, y: 3.0) // Scale for higher resolution
            hostingView.draw(hostingView.bounds)
            NSGraphicsContext.restoreGraphicsState()
            
            // Convert the bitmap to PNG data
            if let pngData = bitmap?.representation(using: .png, properties: [:]) {
                print("Successfully rendered PNG data of size: \(pngData.count) bytes")
                return pngData
            } else {
                print("Failed to create PNG representation from bitmap")
                return nil
            }
        } else {
            print("Failed to create graphics context")
            NSGraphicsContext.restoreGraphicsState()
            return nil
        }
    }
}
