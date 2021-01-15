//
//  MoviesListViewModel.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation
import UIKit
import Combine
import Logging
import SDWebImage

typealias MovieDetailsViewModelDataTuple = (header: MovieDetailsHeaderModel,
                                            general: MovieDetailsGeneralInfoModel,
                                            cast: MovieDetailsCastInfoModel)

protocol MovieDetailViewModelProtocol {
    // API Service
    var apiService: APIServiceProtocol? { get }

    // Handlers
    var movieLoaded: ((MovieDetailsViewModelDataTuple) -> ())? { get set }
    var errorHandler: ((ErrorData) -> ())? { get set }

    var currentMovie: Movie? { get set }
    func fetchMovie(imdbID: String)
}

class DefaultMovieDetailViewModel: NSObject, MovieDetailViewModelProtocol {
    var apiService: APIServiceProtocol? = OMDBApiService()

    var movieLoaded: ((MovieDetailsViewModelDataTuple) -> ())?
    var errorHandler: ((ErrorData) -> ())?

    var currentMovie: Movie?

    var subscriptions: Set<AnyCancellable> = Set()

    func fetchMovie(imdbID: String) {
        LoggerService.shared.debug("Getting movie \(imdbID)")

        let endpoint = OMDBApiEndpoint.movieDetail(imdbID: imdbID)
        let publisher: AnyPublisher<Movie, ApiError>? = apiService?.performRequest(to: endpoint,
                                                                                   responseErrorType: OMDBApiResponseError.self)
        publisher?.receive(on: DispatchQueue.main)
                  .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }

            if case let .failure(apiError) = completion {
                LoggerService.shared.error("Got error while on receving movie: \(apiError)")
                self.errorHandler?(OMDBErrorData(apiError: apiError))
            }

        }, receiveValue: { [weak self] movie in
            guard let self = self else { return }
                LoggerService.shared.debug("Got response with \(movie) movie")
                self.currentMovie = movie
                self.movieLoaded?(self.viewData(for: movie))
            
        }).store(in: &subscriptions)
    }

    func viewData(for movie: Movie) -> MovieDetailsViewModelDataTuple {
        let header = MovieDetailsHeaderModel(posterImageUrl: URL(string: movie.poster),
                                             title: movie.title,
                                             year: movie.year)

        let generalInfo = MovieDetailsGeneralInfoModel(categories: movie.genre,
                                                       duration: movie.runtime,
                                                       rating: "⭐ \(movie.imdbRating)",
                                                       synopsis: movie.plot,
                                                       score: movie.imdbRating,
                                                       reviews: movie.imdbVotes,
                                                       popularity: movie.metascore)

        let castInfo = MovieDetailsCastInfoModel(director: movie.director,
                                                 writer: movie.writer,
                                                 actors: movie.actors)
        return (header, generalInfo, castInfo)
    }
}
