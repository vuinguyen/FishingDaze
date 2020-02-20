//
//  JournalPhotoGridViewCell.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 2/17/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalPhotoGridViewCell: UICollectionViewCell {
  @IBOutlet var imageView: UIImageView!

  var image: UIImage? {
    didSet {
      setup()
    }
  }

  private func setup() {
    guard let testName = image else { return }
    imageView.translatesAutoresizingMaskIntoConstraints = true
    imageView.contentMode = .scaleAspectFit
    imageView.image = testName
    layoutIfNeeded()
  }
}
