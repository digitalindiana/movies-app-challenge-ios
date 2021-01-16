//
//  MovieDetailsGeneralInfoView.swift
//  Movies
//
//  Created by Piotr Adamczak on 15/01/2021.
//

import Foundation
import UIKit

struct MovieDetailsGeneralInfoModel {
    var categories: String
    var duration: String
    var rating: String
    var synopsis: String
    var score: String
    var reviews: String
    var popularity: String
}

class MovieDetailsGeneralInfoView: UIView {
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var synopsisTitleLabel: UILabel!
    @IBOutlet weak var synopsisValueLabel: UILabel!

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var scoreValueLabel: UILabel!

    @IBOutlet weak var reviewsLabel: UILabel!
    @IBOutlet weak var reviewsValueLabel: UILabel!

    @IBOutlet weak var popularityLabel: UILabel!
    @IBOutlet weak var popularityValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        synopsisTitleLabel.text = NSLocalizedString("Synopsis", comment: "")
        scoreLabel.text = NSLocalizedString("Score", comment: "")
        reviewsLabel.text = NSLocalizedString("Reviews", comment: "")
        popularityLabel.text = NSLocalizedString("Popularity", comment: "")
    }

    func fill(with model: MovieDetailsGeneralInfoModel) {
        categoriesLabel.text = model.categories
        durationLabel.text = model.duration
        ratingLabel.text = model.rating
        synopsisValueLabel.text = model.synopsis
        scoreValueLabel.text = model.score
        reviewsValueLabel.text = model.reviews
        popularityValueLabel.text = model.popularity
    }
}
