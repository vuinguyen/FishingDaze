//
//  PhotoScrollProtocol.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 2/21/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoScrollDelegate {
  func addPhoto(photoToAdd: UIImage, updatedPhotos: [UIImage])
  func deletePhoto(photoToDelete: UIImage, updatedPhotos: [UIImage])
}
