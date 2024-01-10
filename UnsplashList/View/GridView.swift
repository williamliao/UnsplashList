//
//  GridView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI
import UniformTypeIdentifiers

struct GridView: View {
    
    @ObservedObject var viewModel: GridViewModel
    @Binding var navigationPath: [Route]
    @Binding var currentItem: SideBarItem
    @ObservedObject var downloadManager: DownloadManager

    var body: some View {

        GeometryReader { geometry in
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVGrid(columns: [.init(.adaptive(minimum: 200, maximum: .infinity), spacing: 3)], spacing: 3) {
                        
                        showGridView(viewModel.getItems())

                    }
                    .padding(.all, 10)
                }
            }
        }
    }

    func showGridView(_ array: Array<Any>) -> some View {
        
        return ForEach(0 ..< array.count, id: \.self) { i in
            
            AsyncImage(url: URL(string: viewModel.indexOfModel(index: i).thumb!)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                        
                    VStack {
                        image
                            .resizable()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                viewModel.open(model: viewModel.indexOfModel(index: i))
                                navigationPath.append(.detail)
                            }
                    
                        
                        DownloadButton(item: viewModel.indexOfModel(index: i))
                            .environmentObject(downloadManager)
                            .padding(.top)
                            .padding(.bottom)
                    }
                    
                            .contextMenu {
                                
                                Button("Copy URL") {
                                    UIPasteboard.general.string = ""
                                    UIPasteboard.general.setValue(viewModel.indexOfModel(index: i).raw ?? "", forPasteboardType: UTType.url.identifier)
                                }
                                
                                if currentItem.id == SideBarItemType.yandeList.rawValue ||
                                    currentItem.id == SideBarItemType.yandeFavorite.rawValue {
                                   
                                    Button("Copy Tags") {
                                        UIPasteboard.general.string = ""
                                        UIPasteboard.general.setValue(viewModel.indexOfModel(index: i).tags ?? "", forPasteboardType: UTType.url.identifier)
                                    }
                                }
                                
                                Button("Download") {
                                    downloadManager.downloadFile(for: viewModel.indexOfModel(index: i))
                                }
                                
                            }
                            .overlay(alignment: .topTrailing, content: {
                                
                                HStack(alignment: .top) {
                               
                                    FavoriteIconView(currentSideBarItem: $currentItem, item: viewModel.indexOfModel(index: i))
                                    
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
                @unknown default:
                    Image(systemName: "wifi.exclamationmark")
                        .resizable()
                        .scaledToFit()
                        .onAppear {
                            viewModel.requestMoreItemsIfNeeded(index: i)
                        }
                }
            }
            
        }
        .animation(.interactiveSpring(), value: 3)
    }
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
