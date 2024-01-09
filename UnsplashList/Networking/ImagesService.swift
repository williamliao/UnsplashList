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
    private var loadingTask2: Task<Void, Error>?
    
    override init(endPoint: NetworkManager.NetworkEndpoint = .random, withSession session: Networking = urlSession()) {
        super.init(withSession: session)
    }

    deinit {
        loadingTask?.cancel()
    }
}

extension ImagesService {
    
    func fetchUnsplash<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData, completion: @escaping (APIResult<Any, ServerError>) -> Void) {
        
        guard loadingTask == nil else {
            return
        }
        
        loadingTask = Task {
            
            switch endpoint.dataSource {
                
                case .unsplash:
                   let result = try await self.data(for: endpoint, using: requestData, decodingType: [RandomResponse].self)
                
                    switch result {
                    case .success(let models):
                        
                        var newModels = [UnsplashModel]()
                        
                        for res in models {
                            let model = UnsplashModel(id: res.id, user: res.user, exif: res.exif, location: res.location, raw: res.urls.raw, full: res.urls.full, regular: res.urls.regular, small: res.urls.small, thumb: res.urls.thumb, tags: "")
                            newModels.append(model)
                        }
                        
                        completion(.success(newModels))
                        
                    case .failure(let error):
                        completion(.failure(error as! ServerError))
                    }
                
                case .unsplashSearch:
                    let result = try await self.data(for: endpoint, using: requestData, decodingType: SearchRespone.self)
                
                    switch result {
                    case .success(let models):
                        
                        var newModels = [UnsplashModel]()
                        
                        for res in models.results {
                            let model = UnsplashModel(id: res.id, user: res.user, exif: nil, location: nil, raw: res.urls?.raw, full: res.urls?.full, regular: res.urls?.regular, small: res.urls?.small, thumb: res.urls?.thumb, tags: "")
                            newModels.append(model)
                        }
                        
                        completion(.success(newModels))
                        
                    case .failure(let error):
                        completion(.failure(error as! ServerError))
                    }

                default:
                    break
            }
        }
        
        loadingTask = nil
    }
    
    func fetchYande<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData, completion: @escaping (APIResult<Any, ServerError>) -> Void) {
        
        guard loadingTask2 == nil else {
            return
        }
        
        loadingTask2 = Task {
            switch endpoint.dataSource {
                
            case .yande:
                let result = try await self.data(for: endpoint, using: requestData, decodingType: [Yande].self)
                
                switch result {
                case .success(let models):
                    
                    var newModels = [UnsplashModel]()
                    
                    for res in models {
                        let model = UnsplashModel(id: String(res.id), user: nil, exif: nil, location: nil, raw: res.file_url, full: res.file_url, regular: res.jpeg_url, small: res.jpeg_url, thumb: res.preview_url, tags: "")
                        newModels.append(model)
                    }
                 
                    completion(.success(newModels))
                    
                case .failure(let error):
                    completion(.failure(error as! ServerError))
                }
                
                break
                
                default:
                    break
            }
        }
        
        loadingTask2 = nil
    }
}
