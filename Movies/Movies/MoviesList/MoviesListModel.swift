//
//  MoviesListModel.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation

// MARK: - MoviesListResponse
struct MoviesListResponse: Codable {
    let movies: [MovieMetadata]
    let totalResults, response: String

    enum CodingKeys: String, CodingKey {
        case movies = "Search"
        case totalResults
        case response = "Response"
    }
}

// MARK: - Movie
struct MovieMetadata: Codable, Hashable {
    let title, year, imdbID: String
    let type: MediaType
    let poster: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
}

enum MediaType: String, Codable {
    case movie
    case game
}
