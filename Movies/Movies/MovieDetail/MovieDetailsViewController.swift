//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Piotr Adamczak on 15/01/2021.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    var imdbId: String?

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var movieHeaderView: MovieDetailsHeaderView!

//    var viewModel: ModelsListViewModelProtocol? = DefaultModelsListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movie details", comment: "Movie details")

        configureHandlers()
    }

    func configureHandlers() {
//        errorView.isHidden = true
//        viewModel?.errorHandler = { errorData in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.errorView.isHidden = false
//                self.errorView.show(errorData)
//            }
//        }
//
//        viewModel?.moviesLoaded = { [weak self] _ in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.errorView.isHidden = true
//            }
//        }
    }
}
