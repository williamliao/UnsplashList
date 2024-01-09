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
            
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    EmptyView()
                case .success(let image):
                    image
                        .resizable()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .onTapGesture {
                                navigationPath.append(.url(url: url!))
                            }
                case .failure(_):
                    Image(systemName: "exclamationmark.icloud")
                        .resizable()
                        .scaledToFit()
                @unknown default:
                    EmptyView()
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
