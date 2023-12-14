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
    @Namespace private var namespace
   
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 200, maximum: .infinity), spacing: 3)], spacing: 3) {
                ForEach(0 ..< viewModel.items.count, id: \.self) { i in
                    
                    AsyncImage(url: URL(string: viewModel.items[i].urls.small)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                    .resizable()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                    .aspectRatio(1, contentMode: .fit)
                                    .onTapGesture {
                                        viewModel.open(model: viewModel.items[i])
                                        navigationPath.append(.detail)
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
                .animation(.interactiveSpring(), value: 3)
            }
            .padding(.all, 10)
            .task {
                await MainActor.run {
                    viewModel.loadData { result in
                        
                    }
                }
            }
        }
    }
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
