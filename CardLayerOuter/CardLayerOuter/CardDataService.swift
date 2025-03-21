import Foundation
import AppKit

class CardDataService {
    static let shared = CardDataService()
    
    private init() {}
    
    func loadFightingStyles(from fileURL: URL) -> [String: FightingStyle]? {
        let accessGranted = AppSettings.shared.startAccessingJsonData()
        defer {
            if accessGranted {
                AppSettings.shared.stopAccessingJsonData()
            }
        }
        
        guard accessGranted else {
            print("Failed to access the JSON file. Permission denied.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([String: FightingStyle].self, from: data)
        } catch {
            print("Error loading fighting styles: \(error)")
            return nil
        }
    }
    
    func loadImage(named cardID: String, from directoryURL: URL) -> NSImage? {
        let accessGranted = AppSettings.shared.startAccessingCardImages()
        defer {
            if accessGranted {
                AppSettings.shared.stopAccessingCardImages()
            }
        }
        
        guard accessGranted else {
            print("Failed to access the images directory. Permission denied.")
            return nil
        }
        
        let imageURL = directoryURL.appendingPathComponent("\(cardID).jpg")
        
        // Check if file exists
        guard FileManager.default.fileExists(atPath: imageURL.path) else {
            print("Image not found: \(imageURL.path)")
            return nil
        }
        
        return NSImage(contentsOf: imageURL)
    }
}
