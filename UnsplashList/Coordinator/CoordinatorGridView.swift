//
//  CoordinatorGridView.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

struct GridCoordinatorView: View {

    // MARK: Stored Properties
    @ObservedObject var coordinator: GridViewCoordinator
    @Binding var navigationPath: [Route]

    var body: some View {
        GridView(viewModel: coordinator.gridViewModel, navigationPath: $navigationPath, currentItem: $coordinator.gridViewModel.currentDataItem)
        #if canImport(UIKit)
            .navigation(item: $coordinator.detailViewModel) { DetailView(viewModel: $0, navigationPath: $navigationPath) }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        #elseif canImport(Cocoa)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        #endif
    }

}

class GridViewCoordinator: ObservableObject {

    @Published var gridViewModel: GridViewModel!
    @Published var detailViewModel: DetailViewModel?
    @Published var detailViewCoordinator: DetailViewCoordinator!
    
    private let imagesService: ImagesService
    private unowned let parent: HomeCoordinator

    init(imagesService: ImagesService, parent: HomeCoordinator) {
        self.imagesService = imagesService
        self.parent = parent
        self.gridViewModel = GridViewModel(imagesService: imagesService, coordinator: self)
        
    }

    func open(_ item: ImageModel, downloadManager: DownloadManager) {
        self.detailViewModel = DetailViewModel(items:gridViewModel.items, item: item, downloadManager: downloadManager, coordinator: self)
        self.detailViewCoordinator = DetailViewCoordinator(imagesService: imagesService, detailViewModel: detailViewModel!)
    }
}
