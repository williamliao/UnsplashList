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

    
    @State private var urlStr = ""
    
    var touchImageIndex = 0
    
    var hGridLayout = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        
        ScrollViewReader { value in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(0 ..< viewModel.items.count, id: \.self) { i in
                    
                        let url = URL(string: viewModel.items[i].regular!)
                        let lowResolutionURL = URL(string: viewModel.items[i].thumb ?? "")
                        let fullResolutionURL = URL(string: viewModel.items[i].raw ?? "")
                        
                        DetailPhotoView(url: url!, lowResolutionURL: lowResolutionURL, fullResolutionURL: lowResolutionURL!, navigationPath: $navigationPath)
                    }
                }.padding(.all, 10)
            }
            .scrollTargetBehavior(.paging)
        }
        
//        .toolbar {
//            ToolbarItem {
//                Button("Open in WebView") {
//                    
//                    guard let path = viewModel.item.full, let url = URL(string: path) else {
//                        return
//                    }
//                    
//                    navigationPath.append(.url(url: url))
//                }
//            }
//        }
        .navigationBarBackButtonHidden(true)
        
        #if canImport(UIKit)
        .navigationBarItems(leading: Button(action : {
            navigationPath.removeLast()
        }){
            Image(systemName: "arrow.left")
        })
        #endif
    }
    
    func delayText() async {
        // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        try? await Task.sleep(nanoseconds: 7_500_000_000)
    }
}

//#Preview {
//    StatefulPreviewWrapper([.detail]) { DetailView(viewModel: DetailViewModel(item: UnsplashModel(name: "", url: URL(string: "https://example.com")!), coordinator: GridViewCoordinator(parent: HomeCoordinator())), navigationPath: $0) }
//}
