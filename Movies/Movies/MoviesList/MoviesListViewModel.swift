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
    func fetchMovies(searchedTitle: String)
    func fetchMoreMovies()
}

class DefaultModelsListViewModel: NSObject, ModelsListViewModelProtocol {
    var logger = Logger(label: "DefaultModelsListViewModel")

    var apiService: APIServiceProtocol? = OMDBApiService()
    var dataSource: MoviesDataSource?

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

    func fetchMovies(searchedTitle: String) {
        logger.logLevel = .debug
        logger.debug("Getting movies for \(searchedTitle)")

        let endpoint = OMDBApiEndpoint.movieList(searchedTitle: searchedTitle, page: 0)
        let publisher: AnyPublisher<MoviesListResponse, Error>? = apiService?.performRequest(to: endpoint)

        publisher?.receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.logger.error("Got error while on receving movies: \(error)")
                }

        }, receiveValue: { [weak self] moviesListResponse in
            self?.logger.debug("Got response with \(moviesListResponse.movies.count) movies, total: \(moviesListResponse.totalResults)")
            self?.updateListWith(moviesListResponse.movies)
        }).store(in: &subscriptions)
    }

    func fetchMoreMovies() {

    }

    func clearData() {
        var snapshot = MoviesDataSnapshot()
        snapshot.appendSections([.movies])
        snapshot.deleteAllItems()
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    func updateListWith(_ movies: [MovieMetadata]) {
        var snapshot = MoviesDataSnapshot()
        snapshot.appendSections([.movies])
        snapshot.appendItems(movies)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
