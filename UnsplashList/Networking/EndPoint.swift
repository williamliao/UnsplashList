//
//  EndPoint.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

struct UnsplashAPI {
    static let scheme = "https"
    static let host = "api.unsplash.com"
    static let accessKey = "d0bd0d66796be14d38b9f5e45852397c35457a7479978ff4db3eea2fcd7e2383"
    static let secretKey = "eae916cc369517321edc9bfe58ed024af98753fc3d03e080b0593c7912a7fdf2"
}

struct YandeAPI {
    static let scheme = "https"
    static let host = "yande.re"
}

protocol EndpointKind {
    associatedtype RequestData

    static func prepare(_ request: inout URLRequest,
                        with data: RequestData)
}

struct AccessToken {
    let token: String
    let accesscode: String
}

enum ImageDataSource {
    case unsplash
    case unsplashSearch
    case yande
    case yandeSearch
}

struct Endpoint<Kind: EndpointKind, Response: Decodable> {
    var dataSource: ImageDataSource = .unsplash
    var path: String
    var queryItems = [URLQueryItem]()
    var method: RequestType = .get
    var format: QueryFormat = .json
    var type: QueryType = .body
}

//enum Endpoint {
//    case random(maxResultCount: Int = 100)
//    case search(query: String, maxResultCount: Int = 100)
//}

enum RequestType: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
}

enum QueryFormat {
    case json
    case urlEncoded
}

enum QueryType {
    case body
    case path
}

enum EndpointKinds {
    enum Public: EndpointKind {
        static func prepare(_ request: inout URLRequest,
                            with _: Void) {
            request.cachePolicy = .useProtocolCachePolicy
        }
    }

    enum Private: EndpointKind {
        static func prepare(_ request: inout URLRequest,
                            with accessToken: AccessToken) {
            request.addValue("Bearer \(accessToken.token)",
                             forHTTPHeaderField: "Authorization")
        }
    }
    
    enum Key: EndpointKind {
        static func prepare(_ request: inout URLRequest,
                            with _: Void) {
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.cachePolicy = .useProtocolCachePolicy
        }
    }
}

extension Endpoint where Kind == EndpointKinds.Key, Response == RandomResponse {
    static func random(with count: String) -> Self {
        Endpoint(dataSource:.unsplash ,path: "photos/random", queryItems: [
            URLQueryItem(name: "count", value: count),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Key,
    Response == SearchRespone {
    static func search(for query: String, perPage: String, page: String) -> Self {
        Endpoint(dataSource:.unsplashSearch ,path: "search/photos", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
            //URLQueryItem(name: "orientation", value: "landscape"),
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Key, Response == [Yande] {
    static func yande(with limit: String) -> Self {
        Endpoint(dataSource:.yande, path: "post.json", queryItems: [
            URLQueryItem(name: "limit", value: limit),
        ])
    }
}

extension Endpoint {
    func makeRequest(with data: Kind.RequestData) -> URLRequest? {
        
        var components = URLComponents()
        
        switch dataSource {
            case .unsplash, .unsplashSearch:
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
            case .yande, .yandeSearch:
                components.scheme = YandeAPI.scheme
                components.host = YandeAPI.host
        }
        
        components.path = "/" + path
        components.queryItems = queryItems.isEmpty ? nil : queryItems

        // If either the path or the query items passed contained
        // invalid characters, we'll get a nil URL back:
        guard let url = components.url else {
            return nil
        }

        var request = URLRequest(url: url)
        Kind.prepare(&request, with: data)
        return request
    }
}
