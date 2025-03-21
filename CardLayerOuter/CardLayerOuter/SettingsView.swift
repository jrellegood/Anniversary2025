//
//  SettingsView.swift
//  CardLayerOuter
//
//  Created by Joe Ellegood on 3/21/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var jsonDataPath: String = AppSettings.shared.jsonDataPath?.path ?? "Not set"
    @State private var cardImagesPath: String = AppSettings.shared.cardImagesPath?.path ?? "Not set"
    @State private var showingJsonPicker = false
    @State private var showingImageFolderPicker = false
    
    var body: some View {
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
                        showingJsonPicker = true
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
                        showingImageFolderPicker = true
                    }
                }
            }
        }
        .padding()
        .frame(width: 500, height: 300)
        .fileImporter(
            isPresented: $showingJsonPicker,
            allowedContentTypes: [.json],
            onCompletion: { result in
                switch result {
                case .success(let url):
                    // Grant your app access to the file user selected
                    if url.startAccessingSecurityScopedResource() {
                        AppSettings.shared.updateJsonDataPath(url)
                        jsonDataPath = url.path
                        url.stopAccessingSecurityScopedResource()
                    }
                case .failure(let error):
                    print("Error selecting JSON file: \(error)")
                }
            }
        )
//        .fileImporter(
//            isPresented: $showingImageFolderPicker,
//            allowedContentTypes: [.folder],
//            onCompletion: { result in
//                switch result {
//                case .success(let url):
//                    // Grant your app access to the folder user selected
//                    if url.startAccessingSecurityScopedResource() {
//                        AppSettings.shared.updateCardImagesPath(url)
//                        cardImagesPath = url.path
//                        url.stopAccessingSecurityScopedResource()
//                    }
//                case .failure(let error):
//                    print("Error selecting image folder: \(error)")
//                }
//            }
//        )
    }
}
