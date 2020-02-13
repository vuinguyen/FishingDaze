//
//  JournalPhotoScrollViewCell.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 2/12/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalPhotoScrollViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!

    var image: UIImage? {
        didSet {
            setup()
        }
    }
/*
    override func awakeFromNib() {
      super.awakeFromNib()
    }
 */

    private func setup() {
        guard let testName = image else { return }
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.contentMode = .scaleAspectFit
        imageView.image = testName
        layoutIfNeeded()
    }
}
