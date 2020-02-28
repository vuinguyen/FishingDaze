//
//  PhotoViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 2/24/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PhotoViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var images: [UIImage]?

  struct PhotoModel {
    var image: UIImage?
    var photoModel: Photo? // Photo in Core Data model
  }
  var entryModel: Entry?
  var photoModels: [PhotoModel]?

  //var photoDict: [Photo: UIImage]?

  var photoDict: [UIImage:Photo]?

  init() {

  }

  // TODO
  // we need to pass in both the Entry and the images here
  init(entryModel: Entry, images: [UIImage]) {
    // add to Core Data
    for image in images {
      let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedContext)!
      let photoModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Photo
      photoModel?.entry = entryModel
      self.entryModel = entryModel

      let imageAsData = image.pngData()
      photoModel?.image = imageAsData

      if let photoModel = photoModel {
        self.photoDict = [image: photoModel]
      }
      self.images?.append(image)

      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }

    }
  }


  // TODO
  /*
  static func fetchPhotoViewModel(entryModel: Entry?) -> PhotoViewModel? {
    var photoViewModel: PhotoViewModel?

    guard let entryModel = entryModel else {
      return photoViewModel
    }

    let managedContext = PersistenceManager.shared.managedContext!
    let entryPredicate = NSPredicate(format: "entry == %@", entryModel)

        do {
          let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
          fetchRequest.predicate = entryPredicate
          let photos = try managedContext.fetch(fetchRequest)

          if photos.count == 0 {
            return photoViewModel
          }

          photoViewModel = PhotoViewModel()

          for photo in photos {
            photoViewModel?.photoModels?.append(photo)

            if let dataImage = photo.value(forKey: "image") as? Data {
             let dataAsUIImage = UIImage(data: dataImage)
              photoViewModel?.images?.append(dataAsUIImage)
            }
          }
        } catch let error as NSError {

          print("Could not fetch or save from context. \(error), \(error.userInfo)")
        }
    return photoViewModel
  }
 */

  // TODO
  func photoDictionary() -> [UIImage: Photo]? {
    return self.photoDict
  }

  // TODO
  func photoImages() -> [UIImage]? {
    return self.images
  }
}

// TODO
extension PhotoViewModel: CoreDataFunctions {
  func save() {

  }
}
