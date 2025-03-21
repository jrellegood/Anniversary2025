import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var jsonDataPath: String = AppSettings.shared.jsonDataPath?.path ?? "Not set"
    @State private var cardImagesPath: String = AppSettings.shared.cardImagesPath?.path ?? "Not set"
    
    // Single state variable for file picking
    @State private var isPicking = false
    // Track what we're selecting
    @State private var selectionType: SelectionType = .none
    
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
            }
            
            // Add the dismiss button at the bottom
            Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }
            .keyboardShortcut(.defaultAction)
            .padding()
        }
        .padding()
        .frame(width: 500, height: 300)
        // A single fileImporter that handles both cases
        .fileImporter(
            isPresented: $isPicking,
            allowedContentTypes: selectionType.allowedTypes,
            onCompletion: { result in
                handleSelection(result)
            }
        )
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
}
