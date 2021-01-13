//
//  MoviesListViewModel.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation
import UIKit
import Combine
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

    func fetchMovies(searchedTitle: String)
    func fetchMoreMovies()
}

class DefaultModelsListViewModel: ModelsListViewModelProtocol {
    var apiService: APIServiceProtocol? = OMDBApiService()
    var dataSource: MoviesDataSource?
    var subscriptions: Set<AnyCancellable> = Set()

    func setupDataSource(for collectionView: UICollectionView) {
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView,
                                                        cellProvider: { (collectionView, indexPath, movie) -> UICollectionViewCell? in

            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCell.reuseIdentifier,
                                                                for: indexPath) as? MovieListCell else {
                return UICollectionViewCell()
            }

            cell.movieTitleLabel.text = movie.title
            cell.posterImageView.sd_setImage(with: URL(string: movie.poster))
            return cell
        })
    }

    func fetchMovies(searchedTitle: String) {
        let endpoint = OMDBApiEndpoint.movieList(searchedTitle: searchedTitle, page: 0)
        let publisher: AnyPublisher<MoviesListResponse, Error>? = apiService?.performRequest(to: endpoint)

        publisher?.sink(receiveCompletion: { (error) in
            print(error)
        }, receiveValue: { [weak self] moviesListResponse in
            print(moviesListResponse)
            self?.updateListWith(moviesListResponse.movies)
        }).store(in: &subscriptions)
    }

    func fetchMoreMovies() {

    }

    func updateListWith(_ movies: [MovieMetadata]) {
        var snapshot = MoviesDataSnapshot()
        snapshot.appendSections([.movies])
        snapshot.appendItems(movies)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
}
