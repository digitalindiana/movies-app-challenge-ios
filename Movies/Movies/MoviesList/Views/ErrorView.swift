//
//  ErrorView.swift
//  Movies
//
//  Created by Piotr Adamczak on 14/01/2021.
//

import Foundation
import UIKit

protocol ErrorData {
    var imageName: String { get }
    var errorDescription: String { get }
}

class ErrorView: UIView {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!

    func show(_ errorData: ErrorData) {
        imageView.image = UIImage(named: errorData.imageName)
        errorLabel.text = errorData.errorDescription
    }
}
