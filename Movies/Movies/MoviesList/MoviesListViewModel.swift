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

enum MoviesListSection {
    case movies
}

typealias MoviesDataSource = UICollectionViewDiffableDataSource<MoviesListSection, MovieMetadata>
typealias MoviesDataSnapshot = NSDiffableDataSourceSnapshot<MoviesListSection, MovieMetadata>

protocol ModelsListViewModelProtocol {
    // DataSource for collection view diffable data source
    var dataSource: MoviesDataSource? { get }

    // API Service
    var apiService: APIServiceProtocol? { get }

    // Handlers
    var moviesLoaded: (([MovieMetadata]) -> ())? { get set }
    var errorHandler: ((ErrorData) -> ())? { get set }

    // Setting up the data source for collection view
    func setupDataSource(for collectionView: UICollectionView)
    func clearData(generateError: Bool)

    var currentMovies: [MovieMetadata] { get }

    func fetchMovies(searchedTitle: String)
    func fetchMoreMovies()
}

class DefaultModelsListViewModel: NSObject, ModelsListViewModelProtocol {
    var apiService: APIServiceProtocol? = OMDBApiService()
    var dataSource: MoviesDataSource?

    var moviesLoaded: (([MovieMetadata]) -> ())?
    var errorHandler: ((ErrorData) -> ())?

    var currentMovies: [MovieMetadata] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateListWith(self.currentMovies)
            }
        }
    }

    var isLoadingData = false

    var subscriptions: Set<AnyCancellable> = Set()

    func setupDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { (collectionView, indexPath, movie) -> UICollectionViewCell? in

            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCell.reuseIdentifier,
                                                                for: indexPath) as? MovieListCell {
                cell.movieTitleLabel.text = movie.title
                cell.posterImageView.sd_setImage(with: URL(string: movie.poster))
                return cell
            }
            return UICollectionViewCell()
        })
    }

    func paginationForTerm(_ searchedTitle: String) -> Pagination {
        // If we are searching the same item -> increment page
        if let lastPagination = apiService?.pagination,
               lastPagination.queryItem == searchedTitle {
                return lastPagination.nextPagination()
        } else {
            self.clearData(generateError: false)
            return DefaultPagination(queryItem: searchedTitle)
        }
    }

    func fetchMovies(searchedTitle: String) {
        if isLoadingData {
            return
        }

        let pagination = paginationForTerm(searchedTitle)
        if !pagination.hasMoreData() {
            LoggerService.shared.debug("Got all data for term: \(pagination.queryItem)")
            return
        }

        LoggerService.shared.debug("Getting movies for \(searchedTitle)")

        isLoadingData = true

        let endpoint = OMDBApiEndpoint.movieList(searchedTitle: searchedTitle, page: pagination.currentPage)
        let publisher: AnyPublisher<MoviesListResponse, ApiError>? = apiService?.performRequest(to: endpoint)

        publisher?.receive(on: DispatchQueue.main)
                  .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }

            if case let .failure(apiError) = completion {
                LoggerService.shared.error("Got error while on receving movies: \(apiError)")
                self.errorHandler?(OMDBErrorData(apiError: apiError))
            }

            self.isLoadingData = false

        }, receiveValue: { [weak self] moviesListResponse in
            guard let self = self else { return }

            if let movies = moviesListResponse.movies,
               let totalResultsString = moviesListResponse.totalResults,
               let totalResults = Int(totalResultsString) {

                LoggerService.shared.debug("Got response with \(movies.count) movies, total:\(totalResults)")
                self.currentMovies.append(contentsOf: movies)
                self.apiService?.pagination = pagination.update(savedItems: self.currentMovies.count,
                                                                totalItems: totalResults)
                self.moviesLoaded?(self.currentMovies)

            } else if let error = moviesListResponse.error {
                self.errorHandler?(OMDBErrorData.error(errorDescription: error))
            }

        }).store(in: &subscriptions)
    }

    func fetchMoreMovies() {
        if let lastPagination = apiService?.pagination {
            fetchMovies(searchedTitle: lastPagination.queryItem)
        }
    }

    func clearData(generateError: Bool) {
        self.currentMovies.removeAll()
        apiService?.pagination = nil

        if generateError {
            errorHandler?(OMDBErrorData.emptyQuery)
        }
    }

    func updateListWith(_ movies: [MovieMetadata]) {
        var snapshot = MoviesDataSnapshot()
        snapshot.appendSections([.movies])
        if movies.count == 0 {
            snapshot.deleteAllItems()
        } else {
            snapshot.appendItems(movies)
        }
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
