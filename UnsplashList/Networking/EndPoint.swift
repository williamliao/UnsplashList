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
}

struct YandeAPI {
    static let scheme = "https"
    static let host = "yande.re"
}

struct DanbooruAPI {
    static let scheme = "https"
    static let host = "danbooru.donmai.us"
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
    case danbooru
}

struct APIData: Codable {
    var accessKey: String
    var api_key: String
    var login: String
    var dataBaseUrl: String
    var dataBaseKey: String
}

struct Endpoint<Kind: EndpointKind, Response: Decodable> {
    var dataSource: ImageDataSource = .unsplash
    var path: String
    var queryItems = [URLQueryItem]()
    var method: RequestType = .get
    var format: QueryFormat = .json
    var type: QueryType = .body
    
    static func readApiData() -> APIData? {
        
        do {
            let location = NSString(string: "~/api.plist").expandingTildeInPath
            let data: Data? = try Data(contentsOf: URL(fileURLWithPath: location))
            
            if let fileData = data {
                guard let plist = try PropertyListSerialization.propertyList(from: fileData, options: .mutableContainers, format: nil) as? Dictionary<String, Any> else {return nil}
              
                let dict = plist.compactMapValues { $0 }
                
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let decoder = JSONDecoder()
                let result = try decoder.decode(APIData.self, from: jsonData)
                
                return result
                
            } else {
                return nil
            }
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
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
        
        let data = Endpoint.readApiData()
        
        return Endpoint(dataSource:.unsplash ,path: "photos/random", queryItems: [
            URLQueryItem(name: "count", value: count),
            URLQueryItem(name: "client_id", value: data?.accessKey),
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Key,
    Response == SearchRespone {
    static func search(for query: String, perPage: String, page: Int) -> Self {
        let data = Endpoint.readApiData()
        return Endpoint(dataSource:.unsplashSearch ,path: "search/photos", queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "client_id", value: data?.accessKey),
            //URLQueryItem(name: "orientation", value: "landscape"),
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Key, Response == YandePost {
    static func yande(with limit: String, page: Int) -> Self {
        Endpoint(dataSource:.yande, path: "post.json", queryItems: [
            URLQueryItem(name: "limit", value: limit),
            URLQueryItem(name: "api_version", value: "2"),
            URLQueryItem(name: "page", value: String(page)),
        ])
    }
}

extension Endpoint where Kind == EndpointKinds.Key, Response == Danbooru {
    static func danbooruRandom(with limit: String, page: Int) -> Self {
        
        let data = Endpoint.readApiData()
        
        return Endpoint(dataSource:.danbooru, path: "posts.json", queryItems: [
         //   URLQueryItem(name: "api_key", value: data?.api_key),
        //    URLQueryItem(name: "login", value: data?.login),
            URLQueryItem(name: "random", value: "true"),
            URLQueryItem(name: "limit", value: limit),
            URLQueryItem(name: "page", value: String(page)),
        ])
    }
    
    static func danbooruWithTag(with tag: String, page: String) -> Self {
   
        return Endpoint(dataSource:.danbooru, path: "posts.json", queryItems: [
            URLQueryItem(name: "tags", value: tag),
            URLQueryItem(name: "page", value: page),
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
            case .danbooru:
                components.scheme = DanbooruAPI.scheme
                components.host = DanbooruAPI.host
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
