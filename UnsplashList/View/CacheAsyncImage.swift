//
//  CacheAsyncImage.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI
import UIKit

struct CacheAsyncImage<Content>: View where Content: View{
    
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> Content
    private let imageCache = ImageCache()
    private let imageCacheKey: NSString = "Cached"
    
    init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ){
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        
        if let cached = imageCache.image(for: url) {
            //let _ = print("cached: \(url.absoluteString)")
            content(.success(Image(uiImage: cached)))
        }else{
            //let _ = print("request: \(url.absoluteString)")
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ){ phase in
                cacheAndRender(phase: phase)
            }
        }
    }
    
    @MainActor func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            imageCache.insertImage(image.getUIImage(newSize: CGSize(width: 180, height: 180)), for: url)
        }
        return content(phase)
    }
}

//#Preview {
//    CacheAsyncImage()
//}
