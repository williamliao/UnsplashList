//
//  MacPlugin.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/5/29.
//

import Foundation
import UniformTypeIdentifiers

@objc(Plugin)
protocol Plugin: NSObjectProtocol {
    init()

    func savePanel(for type: UTType, fileName:String) -> URL?
}

#if canImport(AppKit)
import AppKit
class MacPlugin: NSObject, Plugin {
    required override init() {
    }

    func savePanel(for type: UTType, fileName:String) -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [type]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.title = "Save image"
        savePanel.message = "Choose a folder and a name to store the image."
        savePanel.nameFieldLabel = "Image file name:"
        savePanel.nameFieldStringValue = fileName
        return savePanel.runModal() == .OK ? savePanel.url : nil
    }
}
#endif
