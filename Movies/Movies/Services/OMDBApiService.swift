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
    case page, type

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

struct DefaultPagination: Pagination {

    var queryItem: String = ""
    // omdbapi starts pagination from 1 - not from 0..
    // "Error": "The offset specified in a OFFSET clause may not be negative."
    var currentPage: Int = 1
    var savedItems: Int = 0
    var totalItems: Int = 0
    var dataUpdated: Bool = false

    func update(savedItems: Int, totalItems: Int) -> Pagination {
        return DefaultPagination(queryItem: queryItem,
                                 currentPage: currentPage,
                                 savedItems: savedItems,
                                 totalItems: totalItems,
                                 dataUpdated: true)
    }

    func nextPagination() -> Pagination {
        return DefaultPagination(queryItem: queryItem,
                                 currentPage: currentPage + 1,
                                 savedItems: savedItems,
                                 totalItems: totalItems,
                                 dataUpdated: false)
    }
}

class OMDBApiService: APIServiceProtocol {
    fileprivate static var apiKey = "b9bd48a6"
    var baseUrl: String = "http://www.omdbapi.com"
    var pagination: Pagination?
}
