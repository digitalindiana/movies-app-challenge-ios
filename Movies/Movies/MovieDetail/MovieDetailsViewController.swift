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

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var headerView: MovieDetailsHeaderView!
    @IBOutlet weak var generalInfoView: MovieDetailsGeneralInfoView!
    @IBOutlet weak var castInfoView: MovieDetailsCastInfoView!
    @IBOutlet weak var errorView: ErrorView!

    var viewModel: MovieDetailViewModelProtocol? = DefaultMovieDetailViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Movie details", comment: "Movie details")
        navigationItem.largeTitleDisplayMode = .never

        headerView.playButton.addTarget(self,
                                        action: #selector(MovieDetailsViewController.playButtonTapped(sender:)),
                                        for: .touchUpInside)

        configureHandlers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let imdbId = imdbId {
            viewModel?.fetchMovie(imdbID: imdbId)
        }
    }

    func configureHandlers() {
        errorView.isHidden = true
        viewModel?.errorHandler = { errorData in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorView.isHidden = false
                self.contentStackView.isHidden = true
                self.errorView.show(errorData)
            }
        }

        viewModel?.movieLoaded = { [weak self] viewData in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.errorView.isHidden = true
                self.contentStackView.isHidden = false
                self.headerView.fill(with: viewData.header)
                self.generalInfoView.fill(with: viewData.general)
                self.castInfoView.fill(with: viewData.cast)
            }
        }
    }

    @objc func playButtonTapped(sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Warning ⚠️", comment: ""),
                                      message: NSLocalizedString("Playback not supported 😥", comment: ""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay..", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
