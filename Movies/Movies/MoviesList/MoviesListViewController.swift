//
//  MoviesListViewController.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import UIKit

class MoviesListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let numberOfCellsPerRow: CGFloat = 2

    var viewModel: ModelsListViewModelProtocol? = DefaultModelsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movies list", comment: "Title of Movies List Controller")

        configureCollectionViewLayout()
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

}

