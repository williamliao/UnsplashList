//
//  GridViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class GridViewModel: ObservableObject {
    @Published var items = [UnsplashModel]()
    @Published var error: ServerError?
    @Published var isSearch: Bool = false
    @Published var currentDataItem: SideBarItem

    private unowned let coordinator: GridViewCoordinator
    private let imagesService: ImagesService
    
    @AppStorage("favoriteItems") var favoriteItems: [UnsplashModel] = []
    @AppStorage("favoriteItems2") var favoriteItems2: [UnsplashModel] = []
    @AppStorage("favoriteItems3") var favoriteItems3: [UnsplashModel] = []

    // MARK: 1 Configuration
    private let itemsFromEndThreshold = 5
        
    // MARK: 2 API Pagination data
    private var totalItemsAvailable: Int? = 1000
    private var maximumDownloadItem: Int = 20
    private var itemsLoadedCount: Int?
    @Published var dataIsLoading = false
    private var canLoadMorePages = true
    
    private var query:String = ""
    private var currentPage:Int = 1
    
    init(imagesService: ImagesService, coordinator: GridViewCoordinator) {
        self.imagesService = imagesService
        self.coordinator = coordinator
        currentDataItem = .list
    }
    
    func open(model:UnsplashModel, downloadManager: DownloadManager) {
        coordinator.open(model, downloadManager: downloadManager)
    }
    
    func indexOfModel(index: Int) -> UnsplashModel {
        return items[index]
    }
    
    func getItems() -> [UnsplashModel] {
        return items
    }
    
    func change(_ item: SideBarItem) {
        
        self.removeAll()
        
        isSearch = false
        query = ""
        currentPage = 1
        
        currentDataItem = item
        
        Task {
            await MainActor.run {
                
                if item.id == SideBarItemType.unsplashList.rawValue {
                    loadData()
                } else if item.id == SideBarItemType.unsplashFavorite.rawValue  {
                    loadSaveUnsplashData()
                } else if item.id == SideBarItemType.yandeList.rawValue {
                    loadYandeData()
                } else if item.id == SideBarItemType.yandeFavorite.rawValue {
                    loadSaveYandeData()
                } else if item.id == SideBarItemType.danbooruList.rawValue {
                    loadDanbooru()
                } else if item.id == SideBarItemType.danbooruFavorite.rawValue {
                    loadSaveDanbooru()
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
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
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
    
    func loadSaveDanbooru() {
        self.items.append(contentsOf: favoriteItems3)
    }
    
    func loadDanbooru() {
      
        self.imagesService.fetchDanbooru(for: .danbooruRandom(with: "10"), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
                    }
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadDanbooruSearch(tag: String, page: String) {
        
        query = tag
        
        self.imagesService.fetchDanbooru(for: .danbooruWithTag(with: tag, page: page), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
                    }
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadYandeData() {
        
//        if dataIsLoading {
//            return
//        }
        
        dataIsLoading = true

        self.imagesService.fetchYande(for: .yande(with: "10"), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
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
        
        performSearch()
        
        self.query = query
        
        let lowercasedSearchText = query.lowercased()

        var matchingImages: [UnsplashModel] = []

        items.forEach { model in
            let searchContent = model.tags
            if searchContent?.lowercased().range(of: lowercasedSearchText, options: .caseInsensitive) != nil {
               matchingImages.append(model)
            }
        }
        
        self.imagesService.fetchUnsplash(for: .search(for: lowercasedSearchText, perPage: "10", page: "1"), using: ()) { result in
            
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    if let models = models as? [UnsplashModel] {
                        self.items.append(contentsOf: models)
                        
                        if matchingImages.count > 0 {
                            self.items.append(contentsOf: matchingImages)
                        }
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
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
    
    func removeAll() {
        items.removeAll()
    }
    
    func shouldLoadData(item: UnsplashModel) -> Bool {
        let lastImage = items[items.count - 1]
        return lastImage.id == item.id
    }
    
    @MainActor func requestMoreItemsIfNeeded(index: Int) {
        guard let itemsLoadedCount = itemsLoadedCount,
              let totalItemsAvailable = totalItemsAvailable else {
            return
        }
        
        if dataIsLoading {
            return
        }
        
        if thresholdMeet(itemsLoadedCount, index) &&
            moreItemsRemaining(itemsLoadedCount, totalItemsAvailable) {
            
            // Request next page
            if currentDataItem.id == SideBarItemType.unsplashList.rawValue {
                if isSearch {
                    currentPage += currentPage
                    loadSearchData(query, "10", String(currentPage))
                } else {
                    loadData()
                }
            } else if currentDataItem.id == SideBarItemType.yandeList.rawValue {
                loadYandeData()
            } else if currentDataItem.id == SideBarItemType.danbooruList.rawValue {
                if isSearch {
                    currentPage += currentPage
                    loadDanbooruSearch(tag: query, page: String(currentPage))
                } else {
                    loadDanbooru()
                }
            }
        
        }
    }

    private func thresholdMeet(_ itemsLoadedCount: Int, _ index: Int) -> Bool {
        return (itemsLoadedCount - index) == itemsFromEndThreshold
    }

    private func moreItemsRemaining(_ itemsLoadedCount: Int, _ totalItemsAvailable: Int) -> Bool {
        return itemsLoadedCount < totalItemsAvailable
    }
}
