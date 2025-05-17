import SwiftUI
import UniformTypeIdentifiers
import UserNotifications

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var jsonDataPath: String = AppSettings.shared.jsonDataPath?.path ?? "Not set"
    @State private var cardImagesPath: String = AppSettings.shared.cardImagesPath?.path ?? "Not set"
    
    // Export progress states
    @State private var isExporting = false
    @State private var exportProgress: Double = 0
    @State private var currentExportStyle: String = ""
    @State private var cardsExported: Int = 0
    @State private var totalCardsToExport: Int = 0
    
    // File picking
    @State private var isPicking = false
    @State private var selectionType: SelectionType = .none
    @State private var isExportFolderPicking = false
    
    // Loading state for styles
    @State private var fightingStyles: [String: FightingStyle] = [:]
    @State private var isLoadingStyles = false
    
    enum SelectionType {
        case none
        case jsonFile
        case imageFolder
        
        var allowedTypes: [UTType] {
            switch self {
            case .none:
                return []
            case .jsonFile:
                return [.json]
            case .imageFolder:
                return [.folder]
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Data Files")) {
                    HStack {
                        Text("JSON Data File:")
                        Spacer()
                        Text(jsonDataPath)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button("Browse") {
                            selectionType = .jsonFile
                            isPicking = true
                        }
                    }
                    
                    HStack {
                        Text("Card Images Folder:")
                        Spacer()
                        Text(cardImagesPath)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Button("Browse") {
                            selectionType = .imageFolder
                            isPicking = true
                        }
                    }
                }
                
                Section(header: Text("Card Export")) {
                    Button(action: {
                        loadStylesAndStartExport()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Export All Cards as PNG")
                        }
                    }
                    .disabled(isExporting || AppSettings.shared.jsonDataPath == nil)
                    
                    if isExporting {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exporting cards from style: \(currentExportStyle)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Progress: \(cardsExported) of \(totalCardsToExport) cards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            ProgressView(value: exportProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            // Add the dismiss button at the bottom
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding()
        }
        .padding()
        .frame(width: 500, height: 350)
        // File importer for settings
        .fileImporter(
            isPresented: $isPicking,
            allowedContentTypes: selectionType.allowedTypes,
            onCompletion: { result in
                handleSelection(result)
            }
        )
        // File export dialog
        .fileImporter(
            isPresented: $isExportFolderPicking,
            allowedContentTypes: [.folder],
            onCompletion: { result in
                handleExportFolderSelection(result)
            }
        )
        .alert(isPresented: $isLoadingStyles) {
            Alert(
                title: Text("Loading Styles"),
                message: Text("Loading fighting styles for export..."),
                primaryButton: .default(Text("OK")),
                secondaryButton: .cancel(Text("Cancel")) {
                    isLoadingStyles = false
                }
            )
        }
    }
    
    private func handleSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            // Grant your app access to the file user selected
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access the selected file/folder")
                return
            }
            
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            // Handle based on what we're currently selecting
            switch selectionType {
            case .jsonFile:
                AppSettings.shared.updateJsonDataPath(url)
                jsonDataPath = url.path
                
            case .imageFolder:
                AppSettings.shared.updateCardImagesPath(url)
                cardImagesPath = url.path
                
            case .none:
                break
            }
            
        case .failure(let error):
            print("Error selecting file: \(error)")
        }
        
        // Reset selection type
        selectionType = .none
    }
    
    private func loadStylesAndStartExport() {
        guard let jsonPath = AppSettings.shared.jsonDataPath else {
            print("JSON path not set")
            return
        }
        
        print("Loading fighting styles from: \(jsonPath.path)")
        
        // Load styles directly without showing the alert
        // This alert might be blocking the UI updates
        DispatchQueue.global(qos: .userInitiated).async {
            let styles = CardDataService.shared.loadFightingStyles(from: jsonPath)
            
            DispatchQueue.main.async {
                if let styles = styles {
                    print("Successfully loaded \(styles.count) styles")
                    self.fightingStyles = styles
                    self.isExportFolderPicking = true
                } else {
                    print("Failed to load fighting styles")
                }
            }
        }
    }
    
    private func handleExportFolderSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let folderURL):
            print("Selected export folder: \(folderURL.path)")
            
            // Start export process with security-scoped bookmarks
            let hasAccess = folderURL.startAccessingSecurityScopedResource()
            print("Has security-scoped access: \(hasAccess)")
            
            if hasAccess {
                // Keep reference to the security-scoped bookmark
                saveFolderBookmark(folderURL)
                
                // This is important: keep the folder URL accessible for the duration of export
                // We'll release access once export is complete
                DispatchQueue.global(qos: .userInitiated).async {
                    // Start the export process
                    self.startCardExport(to: folderURL)
                    
                    // Once complete, stop accessing the resource
                    folderURL.stopAccessingSecurityScopedResource()
                    print("Stopped accessing security-scoped resource")
                }
            } else {
                print("Failed to access the selected export folder: permission denied")
                showExportError("Permission denied to access the selected folder.")
            }
            
        case .failure(let error):
            print("Error selecting export folder: \(error)")
            showExportError("Failed to select export folder: \(error.localizedDescription)")
        }
    }
    
    // Save bookmark for later access to this folder
    private func saveFolderBookmark(_ url: URL) {
        do {
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark,
                                                   includingResourceValuesForKeys: nil,
                                                   relativeTo: nil)
            UserDefaults.standard.set(bookmarkData, forKey: "lastExportFolderBookmark")
            print("Saved security bookmark for folder")
        } catch {
            print("Failed to create bookmark for export folder: \(error)")
        }
    }
    
    // Show error alert
    private func showExportError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "Export Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func startCardExport(to directory: URL) {
        // Reset progress tracking
        isExporting = true
        exportProgress = 0
        cardsExported = 0
        totalCardsToExport = 0
        currentExportStyle = ""
        
        Logging.default.log("Starting card export to directory: \(directory.path)")
        
        // Count total cards to export
        for (_, style) in fightingStyles {
            totalCardsToExport += style.cards.count
        }
        
        Logging.default.log("Total cards to export: \(totalCardsToExport)")
        
        DispatchQueue.main.async {
            CardExportService.shared.exportAllCards(self.fightingStyles, toDirectory: directory) { exported, total, styleName in
                // Update progress on main thread
                // Update the UI with our progress
                self.cardsExported = exported
                self.currentExportStyle = styleName
                
                // Calculate progress as a fraction (avoiding division by zero)
                if total > 0 {
                    self.exportProgress = Double(exported) / Double(total)
                } else {
                    self.exportProgress = 0
                }
                
                Logging.default.log("Progress update: \(exported)/\(total) cards exported (\(self.exportProgress * 100)%), current style: \(styleName)")
                
                // Check if export is complete
                if exported >= total {
                    Logging.default.log("Export completed")
                    self.isExporting = false
                    
                    // Show completion notification using UNUserNotificationCenter
                    let content = UNMutableNotificationContent()
                    content.title = "Card Export Complete"
                    content.body = "Successfully exported \(total) cards to PNG format."
                    content.sound = UNNotificationSound.default
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            Logging.default.log("Error showing notification: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    private func renderViewAsPNG(_ view: some View) -> Data? {
        print("Starting to render view as PNG (using alternative approach)")
        
        let size = NSSize(width: 375, height: 525)
        let scaleFactor: CGFloat = 3.0
        
        // Create an image representation with higher resolution
        let scaledSize = NSSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Create a new image
        let image = NSImage(size: scaledSize)
        
        // Prepare the hosting view
        let hostingController = NSHostingController(rootView: view.frame(width: size.width, height: size.height))
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        
        // Make sure the view is loaded and ready
        _ = hostingController.view
        
        // Draw into the image
        image.lockFocus()
        
        // Scale the context for higher resolution
        NSGraphicsContext.current?.cgContext.scaleBy(x: scaleFactor, y: scaleFactor)
        
        // Draw the SwiftUI view
        hostingController.view.layer?.render(in: NSGraphicsContext.current!.cgContext)
        
        image.unlockFocus()
        
        // Convert to PNG data
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let pngData = bitmapRep.representation(using: .png, properties: [:]) {
            print("Successfully rendered PNG data of size: \(pngData.count) bytes")
            return pngData
        } else {
            print("Failed to convert NSImage to PNG data")
            return nil
        }
    }
}
