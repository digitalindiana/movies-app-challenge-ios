//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import UIKit

class MoviesListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    let numberOfCellsPerRow: CGFloat = 2

    var viewModel: ModelsListViewModelProtocol? = DefaultModelsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movies list", comment: "Title of Movies List Controller")

        configureCollectionViewLayout()
        configureSearchController()

        viewModel?.setupDataSource(for: collectionView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel?.fetchMovies(searchedTitle: "Marvel")
    }

    func configureCollectionViewLayout() {
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            let horizontalSpacing = flowLayout.minimumInteritemSpacing
            flowLayout.sectionInset = UIEdgeInsets(top: horizontalSpacing, left: horizontalSpacing,
                                                   bottom: horizontalSpacing, right: horizontalSpacing)
            let separatorsWidth = max(0, numberOfCellsPerRow - 1) * horizontalSpacing + 2 * horizontalSpacing
            let cellWidth = (view.frame.width - separatorsWidth)/numberOfCellsPerRow
            flowLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        }
    }

    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.placeholder = NSLocalizedString("Search for movie..", comment: "")
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController!.navigationBar.sizeToFit()
        definesPresentationContext = true
    }
}

extension MoviesListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchedText = searchController.searchBar.text,
                  searchedText.count > 2 else {
            viewModel?.clearData()
            return
        }

        viewModel?.fetchMovies(searchedTitle: searchedText)
    }
}

extension MoviesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true)
    }
}
