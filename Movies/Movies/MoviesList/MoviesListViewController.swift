//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import UIKit

class MoviesListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    var viewModel: ModelsListViewModelProtocol? = DefaultModelsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movies list", comment: "Title of Movies List Controller")

        viewModel?.setupDataSource(for: collectionView)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel?.fetchMovies(searchedTitle: "Marvel")
    }
}

