//
//  NetworkManager.swift
//  CodeableNetworkManager
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/2.
//

import Foundation
#if canImport(UIKit)
import UIKit
#else
import Cocoa
#endif

public enum APIResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

public enum ServerError: Error {
    case encounteredError(Error)
    case statusCodeError(Error)
    case statusCode(NSInteger)
    case statusClientCode(NSInteger)
    case statusBackendCode(NSInteger)
    case etag //304
    case badRequest //400
    case unAuthorized //401
    case forbidden //403
    case notFound //404
    case methodNotAllowed // 405
    case timeOut //408
    case unSupportedMediaType //415
    case rateLimitted //429
    case serverError //500
    case serverUnavailable //503
    case gatewayTimeout //504
    case networkAuthenticationRequired //511
    case httpVersionNotSupported
    case jsonDecodeFailed
    case badData
    case invalidURL
    case invalidImage
    case invalidResponse
    case invalidCacheResponse
    case noHTTPResponse
    case noInternetConnect
    case networkConnectionLost
    case invalidDate
    case unKnown
    
    static func map(_ error: Error) -> ServerError {
        return (error as? ServerError) ?? .encounteredError(error)
    }
    
    var localizedDescription: String {
        switch self {
        case .encounteredError(let error):
            return NSLocalizedString(error.localizedDescription, comment: "")
        case .notFound:
            return NSLocalizedString("notFound", comment: "")
        case .serverError:
            return NSLocalizedString("Internal Server Error", comment: "")
        case .serverUnavailable:
            return NSLocalizedString("server Unavailable", comment: "")
        case .gatewayTimeout:
            return NSLocalizedString("Gateway Timeout", comment: "")
        case .httpVersionNotSupported:
            return NSLocalizedString("HTTP Version Not Supported", comment: "")
        case .networkAuthenticationRequired:
            return NSLocalizedString("Network Authentication Required", comment: "")
        case .timeOut:
            return NSLocalizedString("timeOut", comment: "")
        case .unSupportedMediaType:
            return NSLocalizedString("The media format of the requested data is not supported by the server, so the server is rejecting the request.", comment: "")
        case .jsonDecodeFailed:
            return NSLocalizedString("jsonDecodeFailed", comment: "")
        case .badRequest:
            return NSLocalizedString("badRequest", comment: "")
        case .methodNotAllowed:
            return NSLocalizedString("methodNotAllowed", comment: "")
        case .forbidden:
            return NSLocalizedString("forbidden", comment: "")
        case .badData:
            return NSLocalizedString("badData", comment: "")
        case .statusCodeError(let error):
            return NSLocalizedString("statusCodeError:\(error.localizedDescription)", comment: "")
        case .statusCode(let code):
            return NSLocalizedString("Error With Status Code:\(code)", comment: "")
        case .statusClientCode(let code):
            return NSLocalizedString("Client Error With Status Code:\(code)", comment: "")
        case .statusBackendCode(let code):
            return NSLocalizedString("Backend Error With Status Code:\(code)", comment: "")
        case .invalidURL:
            return NSLocalizedString("invalidURL", comment: "")
        case .invalidImage:
            return NSLocalizedString("invalidImage", comment: "")
        case .invalidResponse:
            return NSLocalizedString("badServerResponse", comment: "")
        case .noHTTPResponse:
            return NSLocalizedString("noHTTPResponse", comment: "")
        case .noInternetConnect:
            return NSLocalizedString("notConnectedToInternet", comment: "")
        case .networkConnectionLost:
            return NSLocalizedString("networkConnectionLost", comment: "")
        case .rateLimitted:
            return NSLocalizedString("Too Many Requests", comment: "")
        case .unAuthorized:
            return NSLocalizedString("Unauthorized, client must authenticate itself to get the requested response", comment: "")
        case .invalidCacheResponse:
            return NSLocalizedString("invalidCacheResponse", comment: "")
        case .unKnown:
            return NSLocalizedString("unknown", comment: "")
        case .etag:
            return NSLocalizedString("etag", comment: "")
        case .invalidDate:
            return NSLocalizedString("invalidDate", comment: "")
        }
    }
}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}

class NetworkManager {
    
    //static let sharedInstance = NetworkManager()

    var format: QueryFormat { return .urlEncoded }
    var type: QueryType { return .path }
    
    private static var cache: URLCache = {
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 100 * 1024 * 1024
        let diskPath = "unsplash"
        
        if #available(iOS 13.0, *) {
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let diskCacheURL = cachesURL.appendingPathComponent(diskPath)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                directory: diskCacheURL
            )
        }
        else {
            #if !targetEnvironment(macCatalyst)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                diskPath: diskPath
            )
            #else
            fatalError()
            #endif
        }
    }()
    
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureClientCodes: CountableRange<Int> = 400..<499
    private var failureBackendCodes: CountableRange<Int> = 500..<511
    var timeoutInterval = 30.0
   // private var task: URLSessionDataTaskProtocol?
    
    enum NetworkEndpoint {
        case random
        case mock(URL)
    }

    typealias JSONTaskCompletionHandler = (Decodable?, ServerError?) -> Void
   
    private var session: Networking
    private var endPoint: NetworkEndpoint
    
    init(endPoint: NetworkEndpoint = .random, withSession session: Networking) {
        self.session = session
        self.endPoint = endPoint
    }
    
    // MARK: - Base
    
    public static var urlSessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfiguration.timeoutIntervalForRequest = 3.0
        sessionConfiguration.timeoutIntervalForResource = 15.0
        sessionConfiguration.urlCache = cache
        sessionConfiguration.waitsForConnectivity = true
        return sessionConfiguration
    }()
    
    internal static func urlSession() -> URLSession {
        let networkingHandler = NetworkingHandler()
        let session = URLSession(configuration: NetworkManager.urlSessionConfiguration, delegate: networkingHandler, delegateQueue: nil)
        return session
    }

    static let defaultHeaders = [
        "Content-Type": "application/json",
        "cache-control": "no-cache",
    ]
    
    internal static func buildHeaders(key: String, value: String) -> [String: String] {
        var headers = defaultHeaders
        headers[key] = value
        return headers
    }
    
    internal static func basicAuthorization(email: String, password: String) -> String {
        let loginString = String(format: "%@:%@", email, password)
        let loginData: Data = loginString.data(using: .utf8)!
        return loginData.base64EncodedString()
    }
    
    func prepareURLComponents() -> URLComponents? {
        switch endPoint {
            case .random:
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/photos/random"
                
                return components

            case .mock(let url):
                
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = "api.testExample.com"
                components.path = url.absoluteString
                
                return components
        }
    }

    func prepareHeaders(credential: String) -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Basic \(credential)"
        headers["Content-Type"] = "application/json"
        return headers
    }
    
    // MARK: - Help Method
    func cancel() {
        
    }
}

// MARK: - Base URLSession

extension NetworkManager {
    
    private func queryParameters(_ parameters: [String: Any]?, urlEncoded: Bool = false) -> String {
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: ".-_")

        var query = ""
        parameters?.forEach { key, value in
            let encodedValue: String
            if let value = value as? String {
                encodedValue = urlEncoded ? value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "" : value
            } else {
                encodedValue = "\(value)"
            }
            query = "\(query)\(key)=\(encodedValue)&"
        }
        return query
    }
    
    private func jsonPrettyPrint(data: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
        let responeData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
        let prettyPrintedString = NSString(data: responeData, encoding: String.Encoding.utf8.rawValue) else { return }
        print(prettyPrintedString)
    }
    
    private func handleHTTPResponse(statusCode: Int) -> ServerError {
       
        if self.failureClientCodes.contains(statusCode) { //400..<499
            switch statusCode {
                case 401:
                    return ServerError.unAuthorized
                case 403:
                    return ServerError.forbidden
                case 404:
                    return ServerError.notFound
                case 405:
                    return ServerError.methodNotAllowed
                case 408:
                    return ServerError.timeOut
                case 415:
                    return ServerError.unSupportedMediaType
                case 429:
                    return ServerError.rateLimitted
                default:
                    return ServerError.statusClientCode(statusCode)
            }
            
        } else if self.failureBackendCodes.contains(statusCode) { //500..<511
            switch statusCode {
                case 500:
                    return ServerError.serverError
                case 503:
                    return ServerError.serverUnavailable
                case 504:
                    return ServerError.gatewayTimeout
                case 511:
                    return ServerError.networkAuthenticationRequired
                default:
                    return ServerError.statusBackendCode(statusCode)
            }
        } else {
            
            // Server returned response with status code different than expected `successCodes`.
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoint mapping."
            ]
            let error = NSError(domain: "NetworkService", code: statusCode, userInfo: info)
            return ServerError.encounteredError(error)
        }
    }

    func saveRequestCache(request: URLRequest, data: Data, httpResponse: HTTPURLResponse) {
        
        guard let cache = NetworkManager.urlSessionConfiguration.urlCache else {
            return
        }
        
        if cache.cachedResponse(for: request) == nil {
            cache.storeCachedResponse(CachedURLResponse(response: httpResponse, data: data, userInfo: [:], storagePolicy: .allowed), for: request)
        }
    }
        
    func loadRequestCacheIfExist(request: URLRequest) -> ImageCacheRespone? {
        if let cachedResponse = NetworkManager.urlSessionConfiguration.urlCache?.cachedResponse(for: request),
            let httpResponse = cachedResponse.response as? HTTPURLResponse,
            let etag = httpResponse.value(forHTTPHeaderField: "Etag"),
            let lastModified = httpResponse.value(forHTTPHeaderField: "Last-Modified"),
            let date = httpResponse.value(forHTTPHeaderField: "Date") {
            
            let model = ImageCacheRespone(httpResponse: httpResponse, data:cachedResponse.data , date: date, etag: etag, lastModified: lastModified)
            print("etag \(etag) data \(date) lastModified \(lastModified)")
            return model
        } else {
            return nil
        }
    }
}

// MARK: - Concurrency

extension NetworkManager {
    
    func data<T: Decodable, K, R>(
        for endpoint: Endpoint<K, R>,
        using requestData: K.RequestData,
        decodingType: T.Type,
        decoder: JSONDecoder = .init()
    ) async throws -> APIResult<T, Error > {
        
        if endpoint.dataSource == .danbooru {
                decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .iso8601)
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 8)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                throw ServerError.invalidDate
            })
        }
        
        guard let request = endpoint.makeRequest(with: requestData), let url = request.url else {
            return .failure(ServerError.badRequest)
        }

        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ServerError.noHTTPResponse)
        }
        
        if self.successCodes.contains(httpResponse.statusCode) {
            
            if data.count == 0 {
                return .failure(ServerError.badData)
            }
            
            do {
                let models = try decoder.decode(decodingType.self, from: data)
                return .success(models)
                
            } catch DecodingError.dataCorrupted(let context) {
                print(context.debugDescription)
                return .failure(ServerError.jsonDecodeFailed)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("\(key.stringValue) was not found, \(context.debugDescription)")
                return .failure(ServerError.jsonDecodeFailed)
            } catch DecodingError.typeMismatch(let type, let context) {
                print("\(type) was expected, \(context.debugDescription)")
                return .failure(ServerError.jsonDecodeFailed)
            } catch DecodingError.valueNotFound(let type, let context) {
                print("no value was found for \(type), \(context.debugDescription)")
                return .failure(ServerError.jsonDecodeFailed)
            } catch {
                return .failure(ServerError.encounteredError(error))
            }
        } else {
            return .failure(self.handleHTTPResponse(statusCode: httpResponse.statusCode))
        }
    }
    
    func data(
        for request: URLRequest
    ) async throws -> APIResult<Data, Error > {
        
        guard let url = request.url else {
            return .failure(ServerError.badRequest)
        }

        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return .failure(ServerError.noHTTPResponse)
        }
        
        if data.count == 0 {
            return .failure(ServerError.badData)
        }
        
        if self.successCodes.contains(httpResponse.statusCode) {
            
            return .success(data)
            
        } else {
            return .failure(self.handleHTTPResponse(statusCode: httpResponse.statusCode))
        }
    }
    
}

// MARK: - URLSessionTaskDelegate

class NetworkingHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // Indicate network status, e.g., offline mode
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OfflineModeOn"), object: nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest: URLRequest, completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        // Indicate network status, e.g., back to online
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OfflineModeOff"), object: nil)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        
        print("willCacheResponse was called")
        
        let mutableUserInfo = proposedResponse.userInfo
        let mutableData = proposedResponse.data;
        let storagePolicy: URLCache.StoragePolicy = .allowedInMemoryOnly
        
        let cacheResponse: CachedURLResponse = CachedURLResponse(response: proposedResponse.response, data: mutableData, userInfo: mutableUserInfo, storagePolicy: storagePolicy)

        let response: URLResponse = proposedResponse.response
        let httpResponse = response as? HTTPURLResponse
        let headers = httpResponse?.allHeaderFields
        
        if let headers = headers {
            print("willCacheResponse headers \(headers)")
        }
        
        completionHandler(cacheResponse)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse) async -> CachedURLResponse? {
        print("willCacheResponse was called")
        
        let mutableUserInfo = proposedResponse.userInfo
        let mutableData = proposedResponse.data;
        let storagePolicy: URLCache.StoragePolicy = .allowedInMemoryOnly
        
        let cacheResponse: CachedURLResponse = CachedURLResponse(response: proposedResponse.response, data: mutableData, userInfo: mutableUserInfo, storagePolicy: storagePolicy)
        
        let response: URLResponse = proposedResponse.response
        let httpResponse = response as? HTTPURLResponse
        let headers = httpResponse?.allHeaderFields
        
        if let headers = headers {
            print("willCacheResponse headers \(headers)")
        }
        
        return cacheResponse
    }
}
