//
//  DetailViewCoordinator.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/14.
//

import SwiftUI

class DetailViewCoordinator: ObservableObject {
    @Published var detailViewModel: DetailViewModel!
    
    private let imagesService: ImagesService

    init(imagesService: ImagesService, detailViewModel:DetailViewModel) {
        self.imagesService = imagesService
        self.detailViewModel = detailViewModel
    }
}

struct DetailCoordinatorView: View {

    // MARK: Stored Properties
    @ObservedObject var coordinator: DetailViewCoordinator
    @Binding var navigationPath: [Route]

    var body: some View {
        DetailView(viewModel: coordinator.detailViewModel, navigationPath: $navigationPath)
            .navigation(item: $coordinator.detailViewModel) { DetailView(viewModel: $0, navigationPath: $navigationPath) }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }

}
