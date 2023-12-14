//
//  ImagesService.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import Foundation
import SwiftUI

class ImagesService: NetworkManager {
    private var loadingTask: Task<Void, Error>?
    
    override init(endPoint: NetworkManager.NetworkEndpoint = .random, withSession session: Networking = urlSession()) {
        super.init(withSession: session)
    }

    deinit {
        loadingTask?.cancel()
    }
}

extension ImagesService {
    
    func fetchUnsplash(completion: @escaping (APIResult<[UnsplashModel], ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            
            let result = try await self.data(for: .random(with: "10"), using: (), decodingType: [UnsplashModel].self)
            
            switch result {
            case .success(let models):
                completion(.success(models))
            case .failure(let error):
                completion(.failure(error as! ServerError))
            }
        }
        
        loadingTask = nil
    }
}
