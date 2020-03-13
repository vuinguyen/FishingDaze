//
//  LocationViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 10/1/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

class LocationViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var address: String?
  var bodyOfWater: String?
  var latitude: Double?
  var longitude: Double?

  var entryModel: Entry?
  var locationModel: Location?  // Location in Core Data model
  var clLocation: CLLocation?

  init() {

  }

  init(entryModel: Entry) {
    // add to Core Data
    let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedContext)!
    locationModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Location
    locationModel?.entry = entryModel
    self.entryModel = entryModel
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }

  }

  static func fetchLocationViewModel(entryModel: Entry?) -> LocationViewModel? {
    var locationViewModel: LocationViewModel?

    guard let entryModel = entryModel else {
      return locationViewModel
    }

    let managedContext = PersistenceManager.shared.managedContext!
    let entryPredicate = NSPredicate(format: "entry == %@", entryModel)

        do {
          let fetchRequest:NSFetchRequest<Location> = Location.fetchRequest()
          fetchRequest.relationshipKeyPathsForPrefetching = [KeyPath.weather.rawValue]
          let locations = try managedContext.fetch(fetchRequest)
          let locationsFound = (locations as NSArray).filtered(using: entryPredicate) as! [NSManagedObject]
          if locationsFound.count >= 1 {

            if let locationFound = locationsFound[0] as? Location {

              locationViewModel = LocationViewModel()
              locationViewModel?.entryModel = entryModel
              locationViewModel?.locationModel = locationFound
            }
          }
        } catch let error as NSError {

          print("Could not fetch or save from context. \(error), \(error.userInfo)")
        }
    return locationViewModel
  }

  func displayAddressinView(UIcompletion: ((String) -> Void)?) {
    guard let location = clLocation else {
      return
    }

    self.latitude = location.coordinate.latitude
    self.longitude = location.coordinate.longitude

    CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
      guard error == nil else {
        print("\(error?.localizedDescription ?? "got an error from reverse geocoding")")
        return
      }

      var address = ""

      if let placemark = placemarks?.first {
        if placemark.subThoroughfare != nil {
          address += placemark.subThoroughfare! + " "
        }
        if placemark.thoroughfare != nil {
          address += placemark.thoroughfare! + "\n"
        }
        if placemark.subLocality != nil {
          address += placemark.subLocality! + "\n"
        }
        if placemark.subAdministrativeArea != nil {
          address += placemark.subAdministrativeArea! + "\n"
        }
        if placemark.postalCode != nil {
          address += placemark.postalCode! + "\n"
        }
        if placemark.country != nil {
          address += placemark.country! + "\n"
        }

        print("address: \(address)")

        if let UIcompletion = UIcompletion {
          DispatchQueue.main.async {
            UIcompletion(address)
          }
        }
      }

    }

  }


  func addressDisplay() -> String? {
    guard let location = locationModel,
      let address = location.address else {
      return ""
    }

    return address
  }

  func bodyOfWaterDisplay() -> String? {
    guard let location = locationModel,
      let bodyOfWater = location.bodyOfWater else {
      return ""
    }

    return bodyOfWater
  }

  func latLongValues() -> (Double, Double)? {
    guard let location = locationModel,
      let latitude = location.latitude as Double?,
      let longitude = location.longitude as Double? else {
        return (0.0, 0.0)
    }

    return (latitude, longitude)
  }
}

extension LocationViewModel: CoreDataFunctions {
  func save() {
    // add to Core Data
    guard let location = locationModel else {
      return
    }

    if let address = address {
      location.address = address
    }

    if let bodyOfWater = bodyOfWater {
      location.bodyOfWater = bodyOfWater
    }

    if let latitude = latitude,
      let longitude = longitude {
      location.latitude = latitude
      location.longitude = longitude
    }

    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }

  }
}



