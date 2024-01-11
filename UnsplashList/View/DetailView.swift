//
//  DetailView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var viewModel: DetailViewModel
    @Binding var navigationPath: [Route]
    @State var id = UUID()
    
    var hGridLayout = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHGrid(rows: hGridLayout) {
                ForEach(0 ..< viewModel.items.count, id: \.self) { i in
                    
                    let url = URL(string: viewModel.items[i].regular!)
                    
                    if viewModel.downloadManager.checkFileExists(for: viewModel.items[i]) {
                         
                         Image(uiImage: viewModel.downloadManager.getImage(for: viewModel.items[i]))
                             .resizable()
                             .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                             .aspectRatio(1, contentMode: .fit)
                         
                     } else {
                         
                         CacheAsyncImage(url: url!) { phase in
                             switch phase {
                             case .empty:
                                 ProgressView()
                             case .success(let image):
                                 image
                                     .resizable()
                                     .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                     .aspectRatio(1, contentMode: .fit)
                                     .onTapGesture {
                                         navigationPath.append(.url(url: url!))
                                     }
                             case .failure(_):
                                 Image(systemName: "wifi.exclamationmark")
                                     .resizable()
                                     .scaledToFit()
                                     .onTapGesture {
                                         id = UUID()
                                     }
                             @unknown default:
                                 Image(systemName: "wifi.exclamationmark")
                                     .resizable()
                                     .scaledToFit()
                             }
                         }
                         .id(id)
                     }
                }
            }.padding(.all, 10)
        }
        .toolbar {
            ToolbarItem {
                Button("Open in WebView") {
                    
                    guard let path = viewModel.item.full, let url = URL(string: path) else {
                        return
                    }
                    
                    navigationPath.append(.url(url: url))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        
        #if canImport(UIKit)
        .navigationBarItems(leading: Button(action : {
            navigationPath.removeLast()
        }){
            Image(systemName: "arrow.left")
        })
        #endif
        
        
    }
}

//#Preview {
//    StatefulPreviewWrapper([.detail]) { DetailView(viewModel: DetailViewModel(item: UnsplashModel(name: "", url: URL(string: "https://example.com")!), coordinator: GridViewCoordinator(parent: HomeCoordinator())), navigationPath: $0) }
//}
