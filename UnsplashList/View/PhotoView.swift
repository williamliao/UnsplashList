//
//  PhotoView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI
import UniformTypeIdentifiers
import Kingfisher

struct PhotoView: View {
    
    @State var i: Int
    @State var imageModel: UnsplashModel
    @Binding var currentItem: SideBarItem
    @Binding var navigationPath: [Route]
    @EnvironmentObject var viewModel: GridViewModel
    @State var id = UUID()

    @State var progress:Float
    
    let imageCache = NSCache<NSString, UIImage>()
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
                    //print("success: \(r)")
                }
                .onFailure { e in
                    // e: KingfisherError
                    print("failure: \(e)")
                }
                .cacheOriginalImage()
                .resizable()
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .onTapGesture {
                    viewModel.open(model: imageModel, downloadManager: downloadManager)
                    navigationPath.append(.detail)
                }
                .contextMenu {
                    
                    Button("Copy URL") {
                        UIPasteboard.general.string = ""
                        UIPasteboard.general.setValue(imageModel.raw ?? "", forPasteboardType: UTType.url.identifier)
                    }
                    
                    if currentItem.id == SideBarItemType.yandeList.rawValue ||
                        currentItem.id == SideBarItemType.yandeFavorite.rawValue {
                       
                        Button("Copy Tags") {
                            UIPasteboard.general.string = ""
                            UIPasteboard.general.setValue(imageModel.tags ?? "", forPasteboardType: UTType.url.identifier)
                        }
                    }
                    
                }
                .overlay(alignment: .topTrailing, content: {
          
                    HStack(alignment: .top) {
                        FavoriteIconView(currentSideBarItem: $currentItem, item: imageModel)
                    }
                    
                })
                .onAppear {
                    viewModel.requestMoreItemsIfNeeded(index: i)
                }
            
            DownloadButton(item: imageModel)
                .environmentObject(downloadManager)
                .padding(.top)
                .padding(.bottom)
        }
    }

    private func cacheImage(iamge: UIImage) {
        imageCache.setObject(iamge, forKey: imageCacheKey)
    }

    private func cachedImage() -> UIImage? {
        return imageCache.object(forKey: imageCacheKey)
    }
}

//#Preview {
//    PhotoView(imageArray: <#Binding<[UnsplashModel]>#>)
//}
