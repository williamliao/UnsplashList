//
//  GridViewModel.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import SwiftUI

class GridViewModel: ObservableObject {
    @Published var items = [UnsplashModel]()
    //@Binding var navigationPath: [Route]

    private unowned let coordinator: GridViewCoordinator
    private let imagesService: ImagesService
    var error: ServerError?
    
    init(imagesService: ImagesService, items: [UnsplashModel] = [UnsplashModel](), coordinator: GridViewCoordinator) {
        self.imagesService = imagesService
        self.items = items
        self.coordinator = coordinator
    }
    
    func open(model:UnsplashModel) {
        coordinator.open(model)
    }
    
    func change(_ index: SideBarItem) {
        coordinator.changeDataSource()
    }
    
    func loadData(onComplete: @escaping (Result<[UnsplashModel], Error>) -> Void) {

        self.imagesService.fetchUnsplash { result in
            
            switch result {
            case .success(let models):
                
                DispatchQueue.main.async {
                    self.items.append(contentsOf: models)
                }
                
                onComplete(.success(models))
               
            case .failure(let error):
                //print(error)
                self.error = error
                onComplete(.failure(error))
            }
        }
    }
}
