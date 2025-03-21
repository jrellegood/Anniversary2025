import Foundation

class AppSettings {
    static let shared = AppSettings()
    
    private(set) var jsonDataPath: URL?
    private(set) var cardImagesPath: URL?
    
    // Store the security bookmarks for persistent access
    private var jsonDataBookmark: Data?
    private var cardImagesBookmark: Data?
    
    private init() {
        loadSavedPaths()
    }
    
    private func loadSavedPaths() {
        // Load bookmarks from UserDefaults
        if let bookmarkData = UserDefaults.standard.data(forKey: "jsonDataBookmark") {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData,
                                 bookmarkDataIsStale: &isStale)
                self.jsonDataPath = url
                self.jsonDataBookmark = bookmarkData
            } catch {
                print("Failed to resolve bookmark: \(error)")
            }
        }
        
        if let bookmarkData = UserDefaults.standard.data(forKey: "cardImagesBookmark") {
            var isStale = false
            do {
                let url = try URL(resolvingBookmarkData: bookmarkData,
                                 bookmarkDataIsStale: &isStale)
                self.cardImagesPath = url
                self.cardImagesBookmark = bookmarkData
            } catch {
                print("Failed to resolve bookmark: \(error)")
            }
        }
    }
    
    func updateJsonDataPath(_ url: URL) {
        do {
            // Create a security-scoped bookmark
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark,
                                                   includingResourceValuesForKeys: nil,
                                                   relativeTo: nil)
            
            // Save both the URL and the bookmark
            self.jsonDataPath = url
            self.jsonDataBookmark = bookmarkData
            
            // Store in UserDefaults
            UserDefaults.standard.set(bookmarkData, forKey: "jsonDataBookmark")
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }
    
    func updateCardImagesPath(_ url: URL) {
        do {
            // Create a security-scoped bookmark
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark,
                                                   includingResourceValuesForKeys: nil,
                                                   relativeTo: nil)
            
            // Save both the URL and the bookmark
            self.cardImagesPath = url
            self.cardImagesBookmark = bookmarkData
            
            // Store in UserDefaults
            UserDefaults.standard.set(bookmarkData, forKey: "cardImagesBookmark")
        } catch {
            print("Failed to create bookmark: \(error)")
        }
    }
    
    // Method to start accessing a resource
    func startAccessingJsonData() -> Bool {
        return jsonDataPath?.startAccessingSecurityScopedResource() ?? false
    }
    
    func stopAccessingJsonData() {
        jsonDataPath?.stopAccessingSecurityScopedResource()
    }
    
    func startAccessingCardImages() -> Bool {
        return cardImagesPath?.startAccessingSecurityScopedResource() ?? false
    }
    
    func stopAccessingCardImages() {
        cardImagesPath?.stopAccessingSecurityScopedResource()
    }
}
