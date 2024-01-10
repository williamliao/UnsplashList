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
    
    var body: some View {
       
        VStack {
            
            let url = URL(string: viewModel.item.full ?? "")
            
            if viewModel.downloadManager.checkFileExists(at: url!) {
                
                Image(uiImage: viewModel.downloadManager.getImage(at: url!))
                    .resizable()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                
            } else {
                AsyncImage(url: url) { phase in
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
                    @unknown default:
                        Image(systemName: "wifi.exclamationmark")
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            
            
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
