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
                                                 using requestData: K.RequestData) async throws -> [ImageModel] {
        
        var newModels = [ImageModel]()
        
        switch endpoint.dataSource {
            
            case .unsplash:
                do {
                    let result = try await self.data(for: endpoint, using: requestData, decodingType: [RandomResponse].self)
                
                    switch result {
                        case .success(let models):
                            
                            for res in models {
                                
                                let tags: String = res.tags?.title ?? ""
                                let fileExtension = res.urls.raw.getPathExtension()
                                
                                let model = ImageModel(id: res.id, create_at: res.user?.updated_at, updated_at: res.user?.updated_at, name: res.user?.name, bio: res.user?.bio, location: res.user?.location,likes: res.user?.total_likes, isFavorite: false, raw: res.urls.raw, full: res.urls.full, regular: res.urls.regular, small: res.urls.small, thumb: res.urls.thumb, tags: tags, fileExtension: fileExtension, service: "unsplash")
                              
                                newModels.append(model)
                            }
                        
                            return newModels
                        
                        case .failure(let error):
                            throw error
                    }
                } catch {
                    throw error
                }
            
            case .unsplashSearch:
            do {
                let result = try await self.data(for: endpoint, using: requestData, decodingType: SearchRespone.self)
            
                switch result {
                case .success(let models):
                    
                    var newModels = [ImageModel]()
                    
                    for res in models.results {
                        let tags: String = res.tags?.first?.type ?? ""
                        let fileExtension = res.urls?.raw.getPathExtension()
                        
                        let model = ImageModel(id: res.id, create_at: res.user?.updated_at, updated_at: res.user?.updated_at, name: res.user?.name, bio: res.user?.bio, location: res.user?.location,likes: res.user?.total_likes, isFavorite: false, raw: res.urls?.raw, full: res.urls?.full, regular: res.urls?.regular, small: res.urls?.small, thumb: res.urls?.thumb, tags: tags, fileExtension: fileExtension, service: "unsplash")
                        
                        newModels.append(model)
                    }
                    
                    return newModels
                    
                case .failure(let error):
                    throw error
                }
            } catch  {
                throw error
            }
               
            default:
                return newModels
        }
        
        
    }
    
    func fetchYande<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData) async throws -> [ImageModel] {
        
        var newModels = [ImageModel]()
        switch endpoint.dataSource {
            
        case .yande:
            do {
                let result = try await self.data(for: endpoint, using: requestData, decodingType: YandePost.self)
                
                switch result {
                case .success(let models):
                    
                    for res in models.posts {
                        let tags: String = res.tags
                        let fileExtension = res.file_url.getPathExtension()
                        
                        let model = ImageModel(id: String(res.id), create_at: String(res.created_at), updated_at: String(res.updated_at), name: res.author, bio: "", location: "", likes: res.score, isFavorite: false, raw: res.file_url, full: res.file_url, regular: res.sample_url, small: res.preview_url, thumb: res.preview_url, tags: tags, fileExtension: fileExtension, service: "yande")
                        
                        newModels.append(model)
                    }
                    
                    return newModels
                    
                case .failure(let error):
                    throw error
                }
            } catch  {
                throw error
            }
            
        default:
            return newModels
        }
        
    }
    
    func fetchDanbooru<K, R>(for endpoint: Endpoint<K, R>,
                             using requestData: K.RequestData) async throws -> [ImageModel] {
        
        var newModels = [ImageModel]()
        do {
            let result = try await self.data(for: endpoint, using: requestData, decodingType: [Danbooru].self)
            
            switch result {
            case .success(let models):
                
                for res in models {
                    let tags: String = res.tag_string
                    
                    let model = ImageModel(id: String(res.id), create_at: "", updated_at: "", name: "", bio: "", location: "", likes: res.score, isFavorite: false, raw: res.large_file_url, full: res.large_file_url, regular: res.file_url, small: res.preview_file_url, thumb: res.preview_file_url, tags: tags, fileExtension: res.file_ext, service: "danbooru")
                    
                    newModels.append(model)
                }
             
                return newModels
                
            case .failure(let error):
                throw error
            }
        } catch {
            throw error
        }
    }
}

extension String {
    func getPathExtension() -> String {
        return (self as NSString).pathExtension
    }
}
