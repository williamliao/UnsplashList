//
//  GridViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class GridViewModel: ObservableObject {
    @Published var items = [UnsplashModel]()
    @Published var items2 = [Yande]()
    @Published var error: ServerError?
    @Published var isSearch: Bool = false
    @Published var currentDataItem: SideBarItem = .list
    @State var isYande: Bool = false

    private unowned let coordinator: GridViewCoordinator
    private let imagesService: ImagesService

    
    init(imagesService: ImagesService, coordinator: GridViewCoordinator) {
        self.imagesService = imagesService
        self.coordinator = coordinator
    }
    
    func open(model:UnsplashModel) {
        coordinator.open(model)
    }
    
    func change(_ item: SideBarItem) {
        coordinator.changeDataSource()
        
        Task {
            await MainActor.run {
                if item.id == 2 {
                    isYande = false
                    currentDataItem = .list
                    loadData()
                } else if item.id == 5 {
                    isYande = true
                    currentDataItem = .list2
                    loadYandeData()
                }
            }
        }
    }
    
    func loadData() {
  
        self.imagesService.fetchUnsplash(for: .random(with: "10"), using: ()) { result in
            
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                    }
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadYandeData() {

        self.imagesService.fetchYande(for: .yande(with: "10"), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [Yande] {
                        self.items2.append(contentsOf: models)
                    }
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    @MainActor func loadSearchData(_ query: String, _ perPage: String, _ page: String) {
        
        if query.count == 0 {
            return
        }
        
        self.imagesService.fetchUnsplash(for: .search(for: query, perPage: "10", page: "1"), using: ()) { result in
            
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                    }
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func performSearch() {
        isSearch = true
    }
}
