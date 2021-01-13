//
//  MovieListCell.swift
//  Movies
//
//  Created by Piotr Adamczak on 13/01/2021.
//

import Foundation
import UIKit

class MovieListCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!

    override func awakeFromNib() {
        self.layer.cornerRadius = 5
    }

    static var reuseIdentifier: String {
        return "MovieListCellIdentifier"
    }
}
