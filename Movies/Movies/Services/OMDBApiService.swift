//
//  OMDBApiService.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation

enum OMDBApiParameter: String {
    case apiKey = "apikey"
    case searchedTitle = "s"
    case item = "i"
    case page = "p"
    case type

    func queryItem(for value: String) -> URLQueryItem {
        return URLQueryItem(name: self.rawValue, value: value)
    }
}

enum OMDBApiEndpoint: Endpoint {
    case movieList(searchedTitle: String, page: Int)

    var path: String {
        return ""
    }

    var method: String {
        return "GET"
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .movieList(searchedTitle: let searchedTitle, page: let page):
            return [apiKeyQueryItem,
                    OMDBApiParameter.type.queryItem(for: MediaType.movie.rawValue),
                    OMDBApiParameter.searchedTitle.queryItem(for: searchedTitle),
                    OMDBApiParameter.page.queryItem(for: "\(page)")]
        }
    }

    // Required api key query item
    var apiKeyQueryItem: URLQueryItem {
        return URLQueryItem(name: OMDBApiParameter.apiKey.rawValue, value: OMDBApiService.apiKey)
    }
}

class OMDBApiService: APIServiceProtocol {
    fileprivate static var apiKey = "b9bd48a6"
    var baseUrl: String = "http://www.omdbapi.com"
}
