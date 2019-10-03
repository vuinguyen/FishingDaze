//
//  LocationViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 10/1/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

protocol LocationViewModelDelegate {
  func saveLocally()
  func saveToCoreData()
}

class LocationViewModel: LocationViewModelDelegate {
  var address: String = ""
  var bodyOfWater: String = ""
  var latitude: Double = 0.0
  var longitude: Double = 0.0


  func saveLocally() {

  }

  func saveToCoreData() {

  }
}



