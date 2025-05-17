import SwiftUI
import AppKit
import os.log

enum Logging {
    static let `default` = Logger(subsystem: "com.joe.CardLayerOuter", category: "default")
}

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
                Logging.default.log("Successfully exported card: \(card.id) to \(fileURL.path)")
                return fileURL
            } else {
                Logging.default.log("Failed to render card \(card.id) to PNG")
                return nil
            }
        } catch {
            Logging.default.log("Error saving card image: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Export all cards for a style
    func exportAllCardsForStyle(_ style: FightingStyle, toDirectory directory: URL, progressHandler: @escaping (Int, Int) -> Void) {
        let totalCards = style.cards.count
        
        // Process each card
        for (index, card) in style.cards.enumerated() {
            Logging.default.log("Exporting card \(index+1) of \(totalCards) for style \(style.styleName)")
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
        
        Logging.default.log("Starting export of \(totalCards) cards from \(totalStyles) styles to \(directory.path)")
        
        // Verify directory access and permissions
        if !verifyDirectoryAccess(directory) {
            Logging.default.log("ERROR: Cannot access destination directory: \(directory.path)")
            // Continue anyway - we'll try to create subdirectories and handle failures per style
        }
        
        // Process each style
        for (styleName, style) in styles {
            currentStyleIndex += 1
            Logging.default.log("Processing style \(currentStyleIndex) of \(totalStyles): \(styleName)")
            
            // Create subfolder for this style within the parent directory
            let styleDirectory = directory.appendingPathComponent(style.styleName, isDirectory: true)
            
            // Try to create the style directory with proper error handling
            if !createDirectoryIfNeeded(styleDirectory) {
                // If we can't create the directory, try exporting directly to parent folder
                print("WARNING: Could not create style subdirectory, exporting cards directly to parent folder")
                exportCardsForStyle(style, toDirectory: directory, currentTotal: totalExportedCards, grandTotal: totalCards, progressHandler: progressHandler)
                totalExportedCards += style.cards.count
                continue
            }
            
            // Export all cards for this style
            exportCardsForStyle(style, toDirectory: styleDirectory, currentTotal: totalExportedCards, grandTotal: totalCards, progressHandler: progressHandler)
            totalExportedCards += style.cards.count
        }
        
        Logging.default.log("Export process completed - exported \(totalExportedCards) of \(totalCards) cards")
    }
    
    // Helper method to verify directory access
    private func verifyDirectoryAccess(_ directory: URL) -> Bool {
        // Check if directory exists
        var isDirectory: ObjCBool = false
        if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                Logging.default.log("Path exists but is not a directory: \(directory.path)")
                return false
            }
            
            // Check if we can write to it
            if !FileManager.default.isWritableFile(atPath: directory.path) {
                Logging.default.log("Directory exists but is not writable: \(directory.path)")
                return false
            }
            
            return true
        }
        
        // If directory doesn't exist, try to create it
        return createDirectoryIfNeeded(directory)
    }
    
    // Helper method to create directory if needed
    private func createDirectoryIfNeeded(_ directory: URL) -> Bool {
        do {
            // Check if directory already exists
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    // Directory exists
                    return true
                } else {
                    // Path exists but is not a directory
                    Logging.default.log("ERROR: Path exists but is not a directory: \(directory.path)")
                    return false
                }
            }
            
            // Create the directory
            Logging.default.log("Creating directory: \(directory.path)")
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            
            // Verify it was created and is writable
            if FileManager.default.fileExists(atPath: directory.path, isDirectory: &isDirectory) &&
               isDirectory.boolValue &&
               FileManager.default.isWritableFile(atPath: directory.path) {
                Logging.default.log("Successfully created directory: \(directory.path)")
                return true
            } else {
                Logging.default.log("Directory was created but may not be writable: \(directory.path)")
                return false
            }
        } catch {
            Logging.default.log("ERROR creating directory \(directory.path): \(error.localizedDescription)")
            return false
        }
    }
    
    // Helper method to export cards for a single style
    private func exportCardsForStyle(_ style: FightingStyle, toDirectory directory: URL, currentTotal: Int, grandTotal: Int, progressHandler: @escaping (Int, Int, String) -> Void) {
        Logging.default.log("Exporting \(style.cards.count) cards for style \(style.styleName) to \(directory.path)")
        
        // Report initial progress for this style
        DispatchQueue.main.async {
            progressHandler(currentTotal, grandTotal, style.styleName)
        }
        
        // Export each card
        for (index, card) in style.cards.enumerated() {
            // Export the card
            let _ = exportCard(card, styleIcon: style.sfSymbol, styleColor: style.accentColor, toDirectory: directory)
            
            // Report progress
            let exportedCount = currentTotal + index + 1
            DispatchQueue.main.async {
                progressHandler(exportedCount, grandTotal, style.styleName)
            }
        }
    }
    
    // Render SwiftUI view as PNG data using NSHostingView
    private func renderViewAsPNG(_ view: some View) -> Data? {
        // For debugging
        Logging.default.log("Starting to render view as PNG")
        
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
            Logging.default.log("Failed to create bitmap")
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
                Logging.default.log("Successfully rendered PNG data of size: \(pngData.count) bytes")
                return pngData
            } else {
                Logging.default.log("Failed to create PNG representation from bitmap")
                return nil
            }
        } else {
            Logging.default.log("Failed to create graphics context")
            NSGraphicsContext.restoreGraphicsState()
            return nil
        }
    }
}
