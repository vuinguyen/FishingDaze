//
//  WeatherViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/6/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation

class WeatherViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var shortNotes: String?
  var fDegrees: Double?

  var locationModel: Location?  // Location in Core Data model
  var weatherModel: Weather?    // Weather in Core Data model

  init() {
  }
  
  func displayWeatherinView(UIcompletion: ((WeatherData) -> Void)?) {

    
  }
}
