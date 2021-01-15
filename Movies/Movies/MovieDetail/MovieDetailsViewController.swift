//
//  MovieDetailsViewController.swift
//  Movies
//
//  Created by Piotr Adamczak on 15/01/2021.
//

import UIKit

class MovieDetailsSegue: UIStoryboardSegue {
    static var identifier = "MovieDetailsSeque"
}

class MovieDetailsViewController: UIViewController {

    var imdbId: String?

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var headerView: MovieDetailsHeaderView!
    @IBOutlet weak var generalInfoView: MovieDetailsGeneralInfoView!
    @IBOutlet weak var castInfoView: MovieDetailsCastInfoView!

    var viewModel: MovieDetailViewModelProtocol? = DefaultMovieDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movie details", comment: "Movie details")
        navigationItem.largeTitleDisplayMode = .never
        
        configureHandlers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let imdbId = imdbId {
            viewModel?.fetchMovie(imdbID: imdbId)
        }
    }

    func configureHandlers() {
        viewModel?.movieLoaded = { [weak self] viewData in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.fill(with: viewData.header)
                self.generalInfoView.fill(with: viewData.general)
                self.castInfoView.fill(with: viewData.cast)
            }
        }
    }
}
