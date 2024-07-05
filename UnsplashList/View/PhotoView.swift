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
    @Binding var imageModel: ImageModel
    @Binding var currentItem: SideBarItem
    @Binding var navigationPath: [Route]
    @EnvironmentObject var viewModel: GridViewModel
    @State var id = UUID()
    @State var isDownloaded = false

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
                .resizing(referenceSize: CGSize(width: 200, height: 200), mode: .aspectFit)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .frame(alignment: .topLeading)
                .clipped()
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
                    .padding(.trailing, 5)
                    .padding(.top, 5)
                    
                })
                .onAppear {
                    Task {
                        await viewModel.requestMoreItemsIfNeeded(index: i)
                    }
                    
                    isDownloaded = downloadManager.isDownloaded
                }
            
            DownloadButton(item: imageModel, isDownloaded: $isDownloaded)
                .environmentObject(downloadManager)
                .padding(.top)
                .padding(.bottom)
                .onChange(of: isDownloaded) { oldValue, newValue in
                    if newValue == false {
                        viewModel.items.removeAll { oldModel in
                            return oldModel.id == imageModel.id
                        }
                        print("delete item at \(i)")
                    }
                }
                
        }
        .padding()
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
