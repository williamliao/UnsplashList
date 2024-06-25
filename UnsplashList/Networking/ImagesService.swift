//
//  ImagesService.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/12.
//

import Foundation
import SwiftUI

class ImagesService: NetworkManager, @unchecked Sendable {
    private var loadingTask: Task<Void, Error>?
    private var loadingTask2: Task<Void, Error>?
    
    override init(endPoint: NetworkManager.NetworkEndpoint = .random, withSession session: Networking) {
        super.init(withSession: session)
    }

    deinit {
        loadingTask?.cancel()
        loadingTask2?.cancel()
    }
}

extension ImagesService {
    
    func runLater(_ function: @escaping @Sendable () -> Void) -> Void {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1, execute: function)
    }
    
//    func getUnsplashList<K: Sendable, R: Sendable>(for endpoint: Endpoint<K, R>,
//                         using requestData: K.RequestData) async -> APIResult<Any, ServerError> {
//            
//        return await withCheckedContinuation { continuation in
//            
//            self.fetchUnsplash(for: endpoint, using: requestData) { result in
//                continuation.resume(returning: result)
//            }
//        }
//    }

    func fetchUnsplash<K, R>(for endpoint: Endpoint<K, R>,
                                                 using requestData: K.RequestData, completion: @escaping (APIResult<[UnsplashModel], ServerError>) -> Void) async {
        
        switch endpoint.dataSource {
            
            case .unsplash:
                do {
                    let result = try await self.data(for: endpoint, using: requestData, decodingType: [RandomResponse].self)
                
                    switch result {
                        case .success(let models):
                            
                            var newModels = [UnsplashModel]()
                            
                            for res in models {
                                
                                let tags: String = res.tags?.title ?? ""
                                
                                let model = UnsplashModel(id: Int(res.id) ?? 0, user: res.user, exif: res.exif, location: res.location, raw: res.urls.raw, full: res.urls.full, regular: res.urls.regular, small: res.urls.small, thumb: res.urls.thumb, tags: tags, fileExtension: "jpg")
                                newModels.append(model)
                            }
                            
                            completion(.success(newModels))
                            
                        case .failure(let error):
                            completion(.failure(error as! ServerError))
                    }
                } catch {
                    completion(.failure(error as! ServerError))
                }
            
            case .unsplashSearch:
            do {
                let result = try await self.data(for: endpoint, using: requestData, decodingType: SearchRespone.self)
            
                switch result {
                case .success(let models):
                    
                    var newModels = [UnsplashModel]()
                    
                    for res in models.results {
                        let model = UnsplashModel(id: Int(res.id) ?? 0, user: res.user, exif: nil, location: nil, raw: res.urls?.raw, full: res.urls?.full, regular: res.urls?.regular, small: res.urls?.small, thumb: res.urls?.thumb, tags: "", fileExtension: "jpg")
                        newModels.append(model)
                    }
                    
                    completion(.success(newModels))
                    
                case .failure(let error):
                    completion(.failure(error as! ServerError))
                }
            } catch  {
                completion(.failure(error as! ServerError))
            }
                break

            default:
                break
        }
    }
    
    func fetchYande<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData, completion: @escaping (APIResult<[UnsplashModel], ServerError>) -> Void) async {
        
        switch endpoint.dataSource {
            
        case .yande:
            do {
                let result = try await self.data(for: endpoint, using: requestData, decodingType: YandePost.self)
                
                switch result {
                case .success(let models):
                    
                    var newModels = [UnsplashModel]()
                    
                    for res in models.posts {
                        let model = UnsplashModel(id: Int(res.id), user: nil, exif: nil, location: nil, raw: res.file_url, full: res.file_url, regular: res.jpeg_url, small: res.jpeg_url, thumb: res.preview_url, tags: "", fileExtension: res.file_ext)
                        newModels.append(model)
                    }
                 
                    completion(.success(newModels))
                    
                case .failure(let error):
                    completion(.failure(error as! ServerError))
                }
            } catch  {
                completion(.failure(error as! ServerError))
            }
            
            break
            
            default:
                break
        }
    }
    
    func fetchDanbooru<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData, completion: @escaping (APIResult<[UnsplashModel], ServerError>) -> Void) async {
        
        do {
            let result = try await self.data(for: endpoint, using: requestData, decodingType: [Danbooru].self)
            
            switch result {
            case .success(let models):
                
                var newModels = [UnsplashModel]()
                
                for res in models {
                    let model = UnsplashModel(id: Int(res.id), user: nil, exif: nil, location: nil, raw: res.file_url, full: res.file_url, regular: res.large_file_url, small: res.large_file_url, thumb: res.preview_file_url, tags: res.tag_string, fileExtension: res.file_ext)
                    newModels.append(model)
                }
             
                completion(.success(newModels))
                
            case .failure(let error):
                completion(.failure(error as! ServerError))
            }
        } catch {
            completion(.failure(error as! ServerError))
        }
    }
}
