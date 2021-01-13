//
//  APIServiceProtocol.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation
import Combine

enum ApiError: Error {
    case wrongUrl
}

protocol Endpoint {
    var path: String { get }
    var method: String { get }
    var queryItems: [URLQueryItem] { get }
}

protocol APIServiceProtocol {
    var baseUrl: String { get }
    func fullUrl(for endpoint: Endpoint) -> URL?
    func performRequest<T: Decodable>(to endpoint: Endpoint) -> AnyPublisher<T, Error>?
}

extension APIServiceProtocol {

    func fullUrl(for endpoint: Endpoint) -> URL? {
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.path = endpoint.path
        urlComponents?.queryItems = endpoint.queryItems
        return urlComponents?.url
    }

    func performRequest<T: Decodable>(to endpoint: Endpoint) -> AnyPublisher<T, Error>? {
        guard let url = fullUrl(for: endpoint) else {
            return Fail(error: ApiError.wrongUrl).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
                .map { $0.data }
                .decode(type: T.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
    }
    
}
