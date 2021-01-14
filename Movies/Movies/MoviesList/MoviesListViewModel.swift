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

    // Setting up the data source for collection view
    func setupDataSource(for collectionView: UICollectionView)
    func clearData()

    var currentMovies: [MovieMetadata] { get }

    func fetchMovies(searchedTitle: String)
    func fetchMoreMovies()
}

class DefaultModelsListViewModel: NSObject, ModelsListViewModelProtocol {
    var logger = Logger(label: "DefaultModelsListViewModel")

    var apiService: APIServiceProtocol? = OMDBApiService()
    var dataSource: MoviesDataSource?

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
            clearData()
            return DefaultPagination(queryItem: searchedTitle)
        }
    }

    func fetchMovies(searchedTitle: String) {
        if isLoadingData {
            return
        }

        logger.logLevel = .debug
        let pagination = paginationForTerm(searchedTitle)
        if !pagination.hasMoreData() {
            logger.debug("Got all data for term: \(pagination.queryItem)")
            return
        }

        logger.debug("Getting movies for \(searchedTitle)")

        isLoadingData = true

        let endpoint = OMDBApiEndpoint.movieList(searchedTitle: searchedTitle, page: pagination.currentPage)
        let publisher: AnyPublisher<MoviesListResponse, Error>? = apiService?.performRequest(to: endpoint)

        publisher?.receive(on: DispatchQueue.main)
                  .sink(receiveCompletion: { [weak self] completion in
            guard let self = self else { return }

            if case let .failure(error) = completion {
                self.logger.error("Got error while on receving movies: \(error)")
            }

            self.isLoadingData = false

        }, receiveValue: { [weak self] moviesListResponse in
            guard let self = self else { return }

            self.logger.debug("Got response with \(moviesListResponse.movies.count) movies, total: \(moviesListResponse.totalResults)")
            self.currentMovies.append(contentsOf: moviesListResponse.movies)
            self.apiService?.pagination = pagination.update(savedItems: self.currentMovies.count,
                                                            totalItems: Int(moviesListResponse.totalResults) ?? 0)

        }).store(in: &subscriptions)
    }

    func fetchMoreMovies() {
        if let lastPagination = apiService?.pagination {
            fetchMovies(searchedTitle: lastPagination.queryItem)
        }
    }

    func clearData() {
        self.currentMovies.removeAll()
        apiService?.pagination = nil
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
