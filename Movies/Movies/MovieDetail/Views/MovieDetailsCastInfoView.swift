//
//  MovieDetailsGeneralInfoView.swift
//  Movies
//
//  Created by Piotr Adamczak on 15/01/2021.
//

import Foundation
import UIKit

struct MovieDetailsCastInfoModel {
    var director: String
    var writer: String
    var actors: String
}

class MovieDetailsCastInfoView: UIView {
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var directorValueLabel: UILabel!

    @IBOutlet weak var writerLabel: UILabel!
    @IBOutlet weak var writerValueLabel: UILabel!

    @IBOutlet weak var actorsLabel: UILabel!
    @IBOutlet weak var actorsValueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        directorLabel.text = NSLocalizedString("Director", comment: "")
        writerLabel.text = NSLocalizedString("Writer", comment: "")
        actorsLabel.text = NSLocalizedString("Actors", comment: "")
    }

    func fill(with model: MovieDetailsCastInfoModel) {
        directorValueLabel.text = model.director
        writerValueLabel.text = model.writer
        actorsValueLabel.text = model.actors
    }
}
