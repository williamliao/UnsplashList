//
//  GridViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class GridViewModel: ObservableObject {
    @Published var items = [UnsplashModel]()
    @Published var items2 = [UnsplashModel]()
    @Published var error: ServerError?
    @Published var isSearch: Bool = false
    @State var currentDataItem: SideBarItem
    @State var isYande: Bool = false

    private unowned let coordinator: GridViewCoordinator
    private let imagesService: ImagesService
    
    @AppStorage("favoriteItems") var favoriteItems: [UnsplashModel] = []
    @AppStorage("favoriteItems2") var favoriteItems2: [UnsplashModel] = []

    
    init(imagesService: ImagesService, coordinator: GridViewCoordinator) {
        self.imagesService = imagesService
        self.coordinator = coordinator
        currentDataItem = .list
    }
    
    func open(model:UnsplashModel) {
        coordinator.open(model)
    }
    
    func change(_ item: SideBarItem) {
        coordinator.changeDataSource()
        
        currentDataItem = item
        
        Task {
            await MainActor.run {
                if item.id == 2 {
                    loadData()
                } else if item.id == 3  {
                    loadSaveUnsplashData()
                } else if item.id == 4 {
                    loadYandeData()
                } else if item.id == 5 {
                    loadSaveYandeData()
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
    
    func loadSaveUnsplashData() {
        self.items.append(contentsOf: favoriteItems)
    }
    
    func loadSaveYandeData() {
        self.items.append(contentsOf: favoriteItems2)
    }
    
    func loadYandeData() {

        self.imagesService.fetchYande(for: .yande(with: "10"), using: ()) { result in
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
