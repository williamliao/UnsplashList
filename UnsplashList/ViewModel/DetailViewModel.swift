//
//  DetailViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class DetailViewModel: ObservableObject {
    
    @Published var item: UnsplashModel
    private unowned let coordinator: GridViewCoordinator
    
    init(item: UnsplashModel, coordinator: GridViewCoordinator) {
        self.item = item
        self.coordinator = coordinator
    }
}
