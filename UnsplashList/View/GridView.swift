//
//  GridView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var viewModel: GridViewModel
    @Binding var navigationPath: [Route]
    @Binding var isYande: Bool
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 200, maximum: .infinity), spacing: 3)], spacing: 3) {
                
                if viewModel.currentDataItem == .list {
                    showGridView(viewModel.items)
                } else {
                    showGridView(viewModel.items2)
                }
                
            }
            .padding(.all, 10)
        }
    }
    
    func showGridView(_ array: Array<Any>) -> some View {
        
        return ForEach(0 ..< array.count, id: \.self) { i in
            
            AsyncImage(url: URL(string: getURL(index: i)!)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                            .resizable()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                viewModel.open(model: viewModel.isSearch ? viewModel.items[i] : viewModel.items[i])
                                navigationPath.append(.detail)
                            }
                            .contextMenu {
                                
                                if isYande {
                                    Button("Copy URL") {
                                        UIPasteboard.general.string = ""
                                        UIPasteboard.general.setValue(viewModel.items2[i].file_url, forPasteboardType: UIPasteboard.general.url?.absoluteString ?? "")
                                    }
                                    Button("Copy Tags") {
                                        UIPasteboard.general.string = ""
                                        UIPasteboard.general.setValue(viewModel.items2[i].tags, forPasteboardType: UIPasteboard.general.url?.absoluteString ?? "")
                                    }
                                } else {
                                    Button("Copy URL") {
                                        UIPasteboard.general.string = ""
                                        UIPasteboard.general.setValue(viewModel.items[i].urls?.full ?? "", forPasteboardType: UIPasteboard.general.url?.absoluteString ?? "")
                                    }
                                }
                            }
                            .overlay(alignment: .bottomTrailing, content: {
                                
                                FavoriteView(item: viewModel.items[i])
                                
                            })
                case .failure(_):
                    Image(systemName: "wifi.exclamationmark")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    Image(systemName: "wifi.exclamationmark")
                        .resizable()
                        .scaledToFit()
                }
            }
            
        }
        .animation(.interactiveSpring(), value: 3)
    }
    
    func getItems(index: Int) -> Any {
        var item: Any
        
        if viewModel.currentDataItem == .list {
            item = viewModel.items[index]
        } else {
            item = viewModel.items2[index]
        }
        
        return item
    }
    
    func getURL(index: Int) -> String? {
        var url: String?
        
        if viewModel.currentDataItem == .list {
            url = viewModel.items[index].urls?.small
        } else {
            url = viewModel.items2[index].preview_url
        }
        
        return url
    }
}

struct FavoriteView: View {

    @State var item: UnsplashModel
    @StateObject private var favoriteVM = FavoriteViewModel()
    @AppStorage("favoriteItems") var favoriteItems: [UnsplashModel] = []
    
    var body: some View {
        Image(systemName: item.isFavorite ? "heart.fill" : "heart")
            .background(.ultraThinMaterial)
            .font(.system(size: 20))
            .onTapGesture {
                updateFavorite()
            }
    }
    
    private func updateFavorite() {
        favoriteVM.updateFavorite(item: item)
        
        if item.isFavorite {
            favoriteItems.append(item)
        } else {
            favoriteItems.removeAll { model in
                model.id == item.id
            }
        }
    }
}

class FavoriteViewModel : ObservableObject {
 
    func updateFavorite(item: UnsplashModel) {
        item.isFavorite = !item.isFavorite
        self.objectWillChange.send()
    }
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
