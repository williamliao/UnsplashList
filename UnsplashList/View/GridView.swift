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
                
                if viewModel.currentDataItem == .list {
                    showGridView(viewModel.items)
                } else {
                    showGridView(viewModel.items2)
                }
                
            }
            .padding(.all, 10)
//            .task {
//                await MainActor.run {
//                    if viewModel.items.count == 0 {
//                        viewModel.loadData()
//                    }
//                }
//            }
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

//#Preview {
//    StatefulPreviewWrapper([.grid]) { GridView(viewModel: GridViewModel(coordinator: CoordinatorGridViewObject()), navigationPath: $0) }
//        .frame(width: .infinity, height: .infinity)
//}
