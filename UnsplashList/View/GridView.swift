//
//  GridView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI
import UniformTypeIdentifiers

struct GridView: View {
    
    @StateObject var viewModel: GridViewModel
    @Binding var navigationPath: [Route]
    @Binding var currentItem: SideBarItem
    
    var body: some View {
 
        GeometryReader { geometry in
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    LazyVGrid(columns: [.init(.adaptive(minimum: 200, maximum: .infinity), spacing: 3)], spacing: 3) {
     
                        if viewModel.getItems().count > 0 {
                            ForEach(viewModel.items.indices , id: \.self) { index in
                                
                                let imageModel = $viewModel.items[index]
                                
                                PhotoView(i:index, imageModel: imageModel, currentItem: $currentItem, navigationPath: $navigationPath, progress: 0.5)
                                    .environmentObject(viewModel)
                                    .id(imageModel.id)
                            }
                            .animation(.interactiveSpring(), value: 3)
                        }
                    }
                    .aspectRatio(1.0 , contentMode: .fill)
                    .padding(.all, 10)
                }
            }
        }
    }
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
