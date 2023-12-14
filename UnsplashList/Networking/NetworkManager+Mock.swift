//
//  NetworkManager+Mock.swift
//  UnsplashList
//
//  Created by 雲端開發部-廖彥勛 on 2023/12/13.
//

import Foundation

protocol Networking {
    func data(
    from url: URL,
    delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
}

extension Networking {
    // If we want to avoid having to always pass 'delegate: nil'
    // at call sites where we're not interested in using a delegate,
    // we also have to add the following convenience API (which
    // URLSession itself provides when using it directly):
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }
}

extension URLSession: Networking {}

class NetworkingMock: Networking {
    var result = Result<Data, Error>.success(Data())
    var nextResponse: URLResponse!

    init(_ response: (URLResponse?)) {
        self.nextResponse = response
    }

    func data(
        from url: URL,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        return try (result.get(), nextResponse)
    }
}
