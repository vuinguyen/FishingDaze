//
//  LocationViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 10/1/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreLocation

/*
protocol LocationViewModelDelegate {
  func saveLocally(entryViewModel: JournalEntryViewModel?)
  func saveToCoreData(entryViewModel: JournalEntryViewModel?)
}
 */

class LocationViewModel {
  var address: String = ""
  var bodyOfWater: String = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0

  weak var entryViewModel: JournalEntryViewModel?
  var locationModel: Location?  // Location in Core Data model
  var clLocation: CLLocation?

  init() {
  }

  // This may become OBE
  init(entryViewModel: JournalEntryViewModel, clLocation: CLLocation) {
    self.entryViewModel = entryViewModel
    self.clLocation = clLocation

    self.latitude = clLocation.coordinate.latitude
    self.longitude = clLocation.coordinate.longitude
  }

  func displayAddressinView(UIcompletion: ((String) -> Void)?) {
    guard let location = clLocation else {
      return
    }

    CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
      guard error == nil else {
        print("\(error?.localizedDescription ?? "got an error from reverse geocoding")")
        return
      }

      if let placemark = placemarks?.first {
        if placemark.subThoroughfare != nil {
          self.address += placemark.subThoroughfare! + " "
        }
        if placemark.thoroughfare != nil {
          self.address += placemark.thoroughfare! + "\n"
        }
        if placemark.subLocality != nil {
          self.address += placemark.subLocality! + "\n"
        }
        if placemark.subAdministrativeArea != nil {
          self.address += placemark.subAdministrativeArea! + "\n"
        }
        if placemark.postalCode != nil {
          self.address += placemark.postalCode! + "\n"
        }
        if placemark.country != nil {
          self.address += placemark.country! + "\n"
        }

        print("address: \(self.address)")

        if let UIcompletion = UIcompletion {
          DispatchQueue.main.async {
            UIcompletion(self.address)
          }
        }
      }

    }

  }

  func saveLocally(entryViewModel: JournalEntryViewModel?) {

  }

  func saveToCoreData(entryViewModel: JournalEntryViewModel?) {

  }


}



