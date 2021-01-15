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

protocol MovieDetailViewModelProtocol {
    // API Service
    var apiService: APIServiceProtocol? { get }

    // Handlers
    var movieLoaded: ((Movie) -> ())? { get set }
    var errorHandler: ((ErrorData) -> ())? { get set }

    var currentMovie: Movie? { get set }
    func fetchMovie(imdbID: String)
}

class DefaultMovieDetailViewModel: NSObject, MovieDetailViewModelProtocol {
    var apiService: APIServiceProtocol? = OMDBApiService()

    var movieLoaded: ((Movie) -> ())?
    var errorHandler: ((ErrorData) -> ())?

    var currentMovie: Movie?

    var subscriptions: Set<AnyCancellable> = Set()

    func fetchMovie(imdbID: String) {
        LoggerService.shared.debug("Getting movie \(imdbID)")

        let endpoint = OMDBApiEndpoint.movieDetail(imdbID: imdbID)
        let publisher: AnyPublisher<Movie, ApiError>? = apiService?.performRequest(to: endpoint,
                                                                                   responseErrorType: OMDBApiResponseError.self)

//        publisher?.receive(on: DispatchQueue.main)
//                  .sink(receiveCompletion: { [weak self] completion in
//            guard let self = self else { return }
//
//            if case let .failure(apiError) = completion {
//                LoggerService.shared.error("Got error while on receving movies: \(apiError)")
//                self.errorHandler?(OMDBErrorData(apiError: apiError))
//            }
//
//        }, receiveValue: { [weak self] movie in
//            guard let self = self else { return }
//
//                LoggerService.shared.debug("Got response with \(movies) movie")
//                self.currentMovie = movie
//                self.movieLoaded?(movie)
//
//            } else if let error = moviesListResponse.error {
//                self.errorHandler?(OMDBErrorData.error(errorDescription: error))
//            }
//
//        }).store(in: &subscriptions)
    }

}
