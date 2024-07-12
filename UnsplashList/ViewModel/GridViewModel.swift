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
    
    func change(_ item: SideBarItem) {
        
        self.removeAll()
        
        isSearch = false
        query = ""
        currentPage = 1
        
        currentDataItem = item
        
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
    
    func loadData() {
        
        self.dataIsLoading = true
        
        Task.detached { @MainActor in
            do {
                let result = try await self.imagesService.fetchUnsplash(for: .random(with: "10"), using: ())
                self.items.append(contentsOf: result)

                self.itemsLoadedCount = self.items.count
                self.dataIsLoading = false
            } catch {
                self.error = error as? ServerError
            }
        }
    }
    
    func loadSaveUnsplashData() {
        Task {
            self.favoriteItems = await fetchSaveModel(keyword: "unsplash")
            self.items.append(contentsOf: self.favoriteItems)
        }
    }
    
    func loadSaveYandeData() {
        Task {
            self.favoriteItems2 = await fetchSaveModel(keyword: "yande")
            self.items.append(contentsOf: self.favoriteItems2)
        }
    }
    
    func loadSaveDanbooru() {
        Task {
            self.favoriteItems3 = await fetchSaveModel(keyword: "danbooru")
            self.items.append(contentsOf: self.favoriteItems3)
        }
    }
    
    func loadDanbooru() {
        
        Task.detached { @MainActor in
            do {
                let models = try await self.imagesService.fetchDanbooru(for: .danbooruRandom(with: "10", page: self.currentPage), using: ())
                self.items.append(contentsOf: models)
                
                self.itemsLoadedCount = self.items.count
                self.dataIsLoading = false
            } catch {
                self.error = error as? ServerError
            }
        }
    }
    
    func loadDanbooruSearch(tag: String, page: String) {
        
        query = tag
    
        Task.detached { @MainActor in
            
            do {
                let models = try await self.imagesService.fetchDanbooru(for: .danbooruWithTag(with: tag, page: page), using: ())
                self.items.append(contentsOf: models)
                
                self.currentPage = self.currentPage + 1
                
                self.itemsLoadedCount = self.items.count
                self.dataIsLoading = false
            } catch {
                self.error = error as? ServerError
            }
        }
    }
    
    func loadYandeData() {

        dataIsLoading = true
        
        Task.detached { @MainActor in
            
            do {
                let result = try await self.imagesService.fetchYande(for: .yande(with: "10", page: self.currentPage), using: ())
                self.items.append(contentsOf: result)
               
                self.currentPage = self.currentPage + 1

                self.itemsLoadedCount = self.items.count
                self.dataIsLoading = false
            } catch {
                self.error = error as? ServerError
            }
            
        }
    }
    
    func loadSearchData(_ query: String, _ perPage: String, _ page: String) {
        
        if query.count == 0 {
            return
        }
        
        performSearch()
        
        self.query = query
        
        let lowercasedSearchText = query.lowercased()

        Task {
            
            do {
                let result = try await self.imagesService.fetchUnsplash(for: .search(for: lowercasedSearchText, perPage: "10", page: currentPage), using: ())
                
                self.items.append(contentsOf: result)
                
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
                self.currentPage = self.currentPage + 1
                self.itemsLoadedCount = self.items.count
                self.dataIsLoading = false
            } catch {
                
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
                    loadSearchData(query, "10", String(currentPage))
                } else {
                    loadData()
                }
            } else if currentDataItem.id == SideBarItemType.yandeList.rawValue {
                loadYandeData()
            } else if currentDataItem.id == SideBarItemType.danbooruList.rawValue {
                if isSearch {
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
