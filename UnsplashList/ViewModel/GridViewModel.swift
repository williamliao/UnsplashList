//
//  GridViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class GridViewModel: ObservableObject, @unchecked Sendable {
    @Published var items = [ImageModel]()
    @Published var error: ServerError?
    @Published var isSearch: Bool = false
    @Published var currentDataItem: SideBarItem
    let dataBaseService = DataBaseService()

    private unowned let coordinator: GridViewCoordinator
    private let imagesService: ImagesService
    
    @AppStorage("favoriteItems") var favoriteItems: [ImageModel] = []
    @AppStorage("favoriteItems2") var favoriteItems2: [ImageModel] = []
    @AppStorage("favoriteItems3") var favoriteItems3: [ImageModel] = []

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
    
    func open(model:ImageModel, downloadManager: DownloadManager) {
        coordinator.open(model, downloadManager: downloadManager)
    }
    
    func indexOfModel(index: Int) -> ImageModel {
        return items[index]
    }
    
    func getItems() -> [ImageModel] {
        return items
    }
    
    @MainActor
    func change(_ item: SideBarItem) async {
        
        self.removeAll()
        
        isSearch = false
        query = ""
        currentPage = 1
        
        currentDataItem = item
        
        if item.id == SideBarItemType.unsplashList.rawValue {
            await loadData()
        } else if item.id == SideBarItemType.unsplashFavorite.rawValue  {
            await loadSaveUnsplashData()
        } else if item.id == SideBarItemType.yandeList.rawValue {
            await loadYandeData()
        } else if item.id == SideBarItemType.yandeFavorite.rawValue {
            await loadSaveYandeData()
        } else if item.id == SideBarItemType.danbooruList.rawValue {
            await loadDanbooru()
        } else if item.id == SideBarItemType.danbooruFavorite.rawValue {
            await loadSaveDanbooru()
        }
    }
    
    func loadData() async {

        await self.imagesService.fetchUnsplash(for: .random(with: "10"), using: ()) { result in
            
            switch result {
            case .success(let models):

                DispatchQueue.main.async {
                    self.items.append(contentsOf: models)

                    self.itemsLoadedCount = self.items.count
                    self.dataIsLoading = false
                }

            case .failure(let error):
                self.error = error
            }
        }
    }
    
    @MainActor
    func loadSaveUnsplashData() async {
        self.favoriteItems = await fetchSaveModel(keyword: "unsplash")
        self.items.append(contentsOf: self.favoriteItems)
    }
    
    @MainActor
    func loadSaveYandeData() async {
        self.favoriteItems2 = await fetchSaveModel(keyword: "yande")
        self.items.append(contentsOf: self.favoriteItems2)
    }
    
    @MainActor
    func loadSaveDanbooru() async {
        self.favoriteItems3 = await fetchSaveModel(keyword: "danbooru")
        self.items.append(contentsOf: self.favoriteItems3)
    }
    
    func loadDanbooru() async {
      
        await self.imagesService.fetchDanbooru(for: .danbooruRandom(with: "10", page: currentPage), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    self.items.append(contentsOf: models)
                    
                    self.itemsLoadedCount = self.items.count
                    self.dataIsLoading = false
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadDanbooruSearch(tag: String, page: String) async {
        
        query = tag
        
        await self.imagesService.fetchDanbooru(for: .danbooruWithTag(with: tag, page: page), using: ()) { result in
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    self.items.append(contentsOf: models)
                    
                    self.itemsLoadedCount = self.items.count
                    self.dataIsLoading = false
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func loadYandeData() async {
        
//        if dataIsLoading {
//            return
//        }
        
        dataIsLoading = true
      
        Task {
            await self.imagesService.fetchYande(for: .yande(with: "10", page: currentPage), using: ()) { result in
                switch result {
                case .success(let models):
                    
                    DispatchQueue.main.async {
                        
                       //let fileId = models.map{ $0.id }
                        
                        //print("fileId \(fileId)")
                        
                        self.currentPage = self.currentPage + 1

                        self.items.append(contentsOf: models)
                        
                        self.itemsLoadedCount = self.items.count
                        self.dataIsLoading = false
                    }
                    
                case .failure(let error):
                    self.error = error
                }
            }
        }
    }
    
    func loadSearchData(_ query: String, _ perPage: String, _ page: String) async {
        
        if query.count == 0 {
            return
        }
        
        performSearch()
        
        self.query = query
        
        let lowercasedSearchText = query.lowercased()

        await self.imagesService.fetchUnsplash(for: .search(for: lowercasedSearchText, perPage: "10", page: currentPage), using: ()) { result in
            
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    self.items.append(contentsOf: models)
                    
                    var matchingImages: [ImageModel] = []

                    self.items.forEach { model in
                        let searchContent = model.tags
                        if searchContent?.lowercased().range(of: lowercasedSearchText, options: .caseInsensitive) != nil {
                           matchingImages.append(model)
                        }
                    }
                    
                    if matchingImages.count > 0 {
                        self.items.append(contentsOf: matchingImages)
                    }
                    
                    self.itemsLoadedCount = self.items.count
                    self.dataIsLoading = false
                }
                
            case .failure(let error):
                self.error = error
            }
        }
    }
  
    func performSearch() {
        isSearch = true
    }
    
    @MainActor func removeAll() {
        items.removeAll()
    }
    
    func shouldLoadData(item: UnsplashModel) -> Bool {
        let lastImage = items[items.count - 1]
        return lastImage.id == item.id
    }
    
    @MainActor func requestMoreItemsIfNeeded(index: Int) async {
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
                    await loadSearchData(query, "10", String(currentPage))
                } else {
                    await loadData()
                }
            } else if currentDataItem.id == SideBarItemType.yandeList.rawValue {
                await loadYandeData()
            } else if currentDataItem.id == SideBarItemType.danbooruList.rawValue {
                if isSearch {
                    currentPage += currentPage
                    await loadDanbooruSearch(tag: query, page: String(currentPage))
                } else {
                    await loadDanbooru()
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
    
    private func fetchSaveModel(keyword: String) async -> [ImageModel] {
        
        let items = await dataBaseService.fetchModel()
        
        return items.compactMap {
            if $0.service == keyword {
                return $0
            } else {
                return nil
            }
        }
    }
}
