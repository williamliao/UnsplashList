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
                        showGridView(viewModel.getItems())
                    }
                    .aspectRatio(1.0 , contentMode: .fill)
                    .padding(.all, 10)
                }
            }
        }
    }

    func showGridView(_ array: Array<Any>) -> some View {
        
        return ForEach(0 ..< array.count, id: \.self) { i in
            
            PhotoView(i:i, imageModel: viewModel.indexOfModel(index: i), currentItem: $currentItem, navigationPath: $navigationPath, progress: 0.5)
                .environmentObject(viewModel)
                .id(viewModel.indexOfModel(index: i).id)
        }
        .animation(.interactiveSpring(), value: 3)
    }
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
