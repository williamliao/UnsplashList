//
//  PhotoView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2024/1/11.
//

import SwiftUI
import UniformTypeIdentifiers

struct PhotoView: View {
    
    @State var i: Int
    @State var imageModel: UnsplashModel
    @Binding var currentItem: SideBarItem
    @Binding var navigationPath: [Route]
    @EnvironmentObject var viewModel: GridViewModel
    @State var id = UUID()
    
    var body: some View {
        let url = imageModel.thumb!
        
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                
                let downloadManager = DownloadManager()
                    
                VStack {
                    image
                        .resizable()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            viewModel.open(model: imageModel, downloadManager: downloadManager)
                            navigationPath.append(.detail)
                        }
                
                    
                    DownloadButton(item: imageModel)
                        .environmentObject(downloadManager)
                        .padding(.top)
                        .padding(.bottom)
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
                
                       
            case .failure(_):
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        viewModel.requestMoreItemsIfNeeded(index: i)
                    }
                    .onTapGesture {
                        id = UUID()
                    }
            @unknown default:
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .onAppear {
                        viewModel.requestMoreItemsIfNeeded(index: i)
                    }
            }
        }
        .id(id)
    }
}

//#Preview {
//    PhotoView(imageArray: <#Binding<[UnsplashModel]>#>)
//}
