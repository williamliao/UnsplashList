//
//  DetailViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class DetailViewModel: ObservableObject {
    
    @Published var items: [UnsplashModel]
    @Published var item: UnsplashModel
    @Published var downloadManager: DownloadManager
    private unowned let coordinator: GridViewCoordinator
    
    init(items: [UnsplashModel], item: UnsplashModel, downloadManager: DownloadManager, coordinator: GridViewCoordinator) {
        self.item = item
        self.downloadManager = downloadManager
        self.coordinator = coordinator
        self.items = items
    }
    
    
}
