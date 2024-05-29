//
//  ImageItem.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/5/29.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
public typealias ImageRepresentable = UIImage
#elseif canImport(AppKit)
public typealias ImageRepresentable = NSImage
#endif

struct ImageItem: Codable, Identifiable {
    var id: String
    var imageData: Data?
}

extension ImageItem {

    var nativeImage: ImageRepresentable? {
        guard let imageData = imageData else {
            return nil
        }
        return ImageRepresentable(data: imageData)
    }
}

extension Image {
    
    init(_ image: ImageRepresentable) {
        #if canImport(UIKit)
        self.init(uiImage: image)
        #elseif canImport(Cocoa)
        self.init(nsImage: image)
        #endif
    }
    
    init(_ systemName: String) {
        #if canImport(UIKit)
        self.init(systemName: systemName)
        #elseif canImport(Cocoa)
        self.init(NSImage(systemSymbolName: systemName, accessibilityDescription: nil)!)
        #endif
    }
    
}

extension ImageItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ImageItem: Equatable {
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id
    }
}
