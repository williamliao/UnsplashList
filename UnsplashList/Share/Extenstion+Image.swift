//
//  Extenstion+Image.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI

extension Image {
    @MainActor
    func getUIImage(newSize: CGSize) -> UIImage? {
        let image = resizable()
            .scaledToFill()
            .frame(width: newSize.width, height: newSize.height)
            .clipped()
        return ImageRenderer(content: image).uiImage
    }
}
