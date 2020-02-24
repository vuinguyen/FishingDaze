//
//  WeatherViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/6/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData

class WeatherViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var shortNotes: String?
  var fDegrees: Double?
  var weatherData: WeatherData?

  var locationModel: Location?  // Location in Core Data model
  var weatherModel: Weather?    // Weather in Core Data model

  init() {
  }

  init(locationModel: Location) {
    // add to Core Data
    let entity = NSEntityDescription.entity(forEntityName: "Weather", in: managedContext)!
    weatherModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Weather
    weatherModel?.location = locationModel
    self.locationModel = locationModel
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }

  }

  static func fetchWeatherViewModel(locationModel: Location?) -> WeatherViewModel? {
    var weatherViewModel: WeatherViewModel?

    guard let locationModel = locationModel else {
      return weatherViewModel
    }

    let managedContext = PersistenceManager.shared.managedContext!
    let entryPredicate = NSPredicate(format: "location == %@", locationModel)

        do {
          let fetchRequest:NSFetchRequest<Weather> = Weather.fetchRequest()
          let weatherPoints = try managedContext.fetch(fetchRequest)
          let weatherPointsFound = (weatherPoints as NSArray).filtered(using: entryPredicate) as! [NSManagedObject]
          if weatherPointsFound.count >= 1 {

            if let weatherFound = weatherPointsFound[0] as? Weather {

              weatherViewModel = WeatherViewModel()
              weatherViewModel?.locationModel = locationModel
              weatherViewModel?.weatherModel = weatherFound

              print("shortNotes: \(weatherViewModel?.shortNotes ?? "")")
              print("fDegrees: \(weatherViewModel?.fDegrees ?? 0.0)")
            }
          }
        } catch let error as NSError {

          print("Could not fetch or save from context. \(error), \(error.userInfo)")
        }
    return weatherViewModel
  }

  func notesDisplay() -> String? {
    guard let weather = weatherModel,
      let notes = weather.shortNotes else {
      return ""
    }

    return notes
  }

  func temperatureDisplay() -> String? {
    guard let weather = weatherModel,
      let temperature = weather.fDegrees as Double? else {
        return ""
      }

    return temperature.description
  }

  func displayWeatherinView(UIcompletion: ((_ temperature: String?, _ notes: String?) -> Void)?) {
    guard let weatherData = weatherData else {
      return
    }

    self.fDegrees = weatherData.fDegrees
    self.shortNotes = weatherData.shortNotes

    let tempDisplay = String(weatherData.fDegrees)
    if let UIcompletion = UIcompletion {
      DispatchQueue.main.async {
        UIcompletion(tempDisplay, self.shortNotes)
      }
    }
  }

}

extension WeatherViewModel: CoreDataFunctions {
  func save() {
    guard let weather = weatherModel else {
      return
    }

    if let fDegrees = fDegrees {
      weather.fDegrees = fDegrees
    }

    if let shortNotes = shortNotes {
      weather.shortNotes = shortNotes
    }
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}
