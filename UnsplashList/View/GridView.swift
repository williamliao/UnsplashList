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
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 200, maximum: .infinity), spacing: 3)], spacing: 3) {
                
                showGridView(viewModel.items)
                
            }
            .padding(.all, 10)
            .task {
                await MainActor.run {
                    if viewModel.items.count == 0 {
                        viewModel.loadData()
                    }
                }
            }
        }
    }
    
    func showGridView(_ array: Array<Any>) -> some View {
        
        return ForEach(0 ..< array.count, id: \.self) { i in
            
            let url = viewModel.items[i].urls?.small
            
            AsyncImage(url: URL(string: url!)) { phase in
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
}

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
