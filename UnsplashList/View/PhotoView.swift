//
//  PhotoView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI
import UniformTypeIdentifiers
import Kingfisher

#if canImport(UIKit)
public typealias PasteboardRepresentable = UIPasteboard
#elseif canImport(AppKit)
public typealias PasteboardRepresentable = NSPasteboard
#endif

struct PhotoView: View {
    
    @State var i: Int
    @State var imageModel: ImageModel
    @Binding var currentItem: SideBarItem
    @Binding var navigationPath: [Route]
    @EnvironmentObject var viewModel: GridViewModel
    @State var id = UUID()

    @State var progress:Float
    
    let imageCache = ImageCache()
    let imageCacheKey: NSString = "CachedImage"
   
    var body: some View {
        let url = imageModel.thumb!
        let downloadManager = DownloadManager()

        VStack {
            KFImage(URL(string: url)!)
                //.placeholder {
                    //
                //}
                .placeholder { progress in
                    CircularProgressView(progress: progress)
                }
                .cancelOnDisappear(true)
                //.retry(maxCount: 3, interval: .seconds(5))
                .onProgress { receivedSize, totalSize in
                    progress = (Float(receivedSize) / Float(totalSize))
                }
                .onSuccess { r in
                    // r: RetrieveImageResult
                    cacheImage(image: r.image, url: r.source.url!)
                }
                .onFailure { e in
                    // e: KingfisherError
                    print("failure: \(e)")
                }
                .onTapGesture {
                    viewModel.open(model: imageModel, downloadManager: downloadManager)
                    navigationPath.append(.detail)
                }
                .contextMenu {
                    
                    Button("Copy URL") {
                        PasteboardRepresentable.general.setString("", forType: .string)
                        PasteboardRepresentable.general.setString(imageModel.raw ?? "", forType: .string)
                    }
                    
                    if currentItem.id == SideBarItemType.yandeList.rawValue ||
                        currentItem.id == SideBarItemType.yandeFavorite.rawValue {
                       
                        Button("Copy Tags") {
                            PasteboardRepresentable.general.setString("", forType: .string)
                            let tags = imageModel.tags ?? ""
                            PasteboardRepresentable.general.setString(tags, forType: .string)
                        }
                    }
                    
                }
                .overlay(alignment: .topTrailing, content: {
          
                    HStack(alignment: .top) {
                        FavoriteIconView(currentSideBarItem: $currentItem, item: imageModel)
                    }
                    
                })
                .onAppear {
                    Task {
                        await viewModel.requestMoreItemsIfNeeded(index: i)
                    }
                }
            
            DownloadButton(item: imageModel)
                .environmentObject(downloadManager)
                .padding(.top)
                .padding(.bottom)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .frame(minHeight: 0, maxHeight: .infinity)
        .clipped()
    }
   
    private func cacheImage(image: ImageRepresentable, url: URL) {
        imageCache.insertImage(image, for: url)
    }

    private func cachedImage(url: URL) -> ImageRepresentable? {
        return imageCache.image(for: url)
    }
}

//#Preview {
//    PhotoView(imageArray: <#Binding<[UnsplashModel]>#>)
//}
