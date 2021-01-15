//
//  MovieDetailsHeaderView.swift
//  Movies
//
//  Created by Piotr Adamczak on 15/01/2021.
//

import Foundation
import UIKit

struct MovieDetailsHeaderModel {
    var posterImageUrl: String?
    let title: String
    let year: String
    let playButtonAction: (() -> Void)?
}

class MovieDetailsHeaderView: UIView {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    func fill(with: MovieDetailsHeaderModel) {
        
    }
}
