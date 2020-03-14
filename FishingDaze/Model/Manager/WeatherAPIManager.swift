//
//  WeatherAPIManager.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/2/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation

struct WeatherData {
  var shortNotes: String
  var fDegrees: Double
}

enum TemperatureUnit: String {
  case fahreinhet
  case celsius 
}

enum WeatherError: Error {
  case generic
  case parsing
}

extension WeatherError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .generic:
      return NSLocalizedString("Error Accessing Weather Service.", comment: "")

    case .parsing:
      return NSLocalizedString("Error Parsing Weather Data", comment: "")
    }
  }
}

protocol WeatherAPIManagerDelegate {
  func weatherManager(_ manager: WeatherAPIManager, didUpdateWeather weatherData: [WeatherData])
  func weatherManager(_ manager: WeatherAPIManager, didFailWithError error: Error)
}

let city = "Raleigh,NC"
let units = "I"

let exampleURL = "https://api.weatherbit.io/v2.0/current?city=Raleigh,NC&key=API_KEY"
let baseURL = "https://api.weatherbit.io/v2.0/current?"

class WeatherAPIManager {

  //var city: String?
  var latitude: Double? = 38.123
  var longitude: Double? = -78.543
  var delegate: WeatherAPIManagerDelegate?

  var currentWeatherURL =
    baseURL +
      "key=\(APIKeys.WeatherBitIOKey)" +
      "&city=\(city)" +
  "&units=\(units)"

  init() {

  }
  
  func requestWeather() {
    startLoad()
  }

  func startLoad() {
    if let latitude = latitude,
      let longitude = longitude {
      currentWeatherURL =
        baseURL +
        "key=\(APIKeys.WeatherBitIOKey)" +
        "&lat=\(latitude)" +
        "&lon=\(longitude)" +
      "&units=\(units)"
    }

    let url = URL(string: currentWeatherURL)!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if error != nil,
        let error = error {
        print("error with weather services: \(error.localizedDescription)")
        if let delegate = self.delegate {
          delegate.weatherManager(self, didFailWithError: error)
        }
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print("Getting weather data: we have a server error here!")
          if let delegate = self.delegate {
            delegate.weatherManager(self, didFailWithError: WeatherError.generic)
          }
          return
      }

      guard let data = data else {
        print("couldn't get weather data! :(")
        if let delegate = self.delegate {
          delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
        }
        return
      }
      print("data is: \(data)")

      do {
        // let's parse some data here!
        // Note: I didn't use JSON Decoding here because the structure of the returned JSON
        // object was really complicated and wasn't worth the trouble to write Decoding classes
        // in order to grab a couple pieces of data, so JSON Serialization was an easier solution

        guard let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
          print("cannot serialize weather json!")
          if let delegate = self.delegate {
            delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
          }
          return
        }
        //print(resultsDictionary)


        guard let count = resultsDictionary["count"] as? Int else {
          print("parsing weather json: cannot get count")
          if let delegate = self.delegate {
            delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
          }
          return
        }
        print("Int: \(count)")

        guard let firstData = resultsDictionary["data"] as? [[String: AnyObject]] else {
          print("parsing weather json: cannot get forecast")
          if let delegate = self.delegate {
            delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
          }
          return
        }
        print("forecast is: \(firstData[0])")

        guard let forecast = firstData[0] as [String: AnyObject]?,
          let temperature = forecast["temp"] as? Double else {
            print("parsing weather json: cannot get temperature")
            if let delegate = self.delegate {
              delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
            }
            return
        }
        print("temperature is: \(temperature)")

        guard let weather = forecast["weather"] as? [String: AnyObject],
          let weatherDescription = weather["description"] as? String else {
            print("parsing weather json: cannot get weather description")
            if let delegate = self.delegate {
              delegate.weatherManager(self, didFailWithError: WeatherError.parsing)
            }
            return
        }
        print("weather description is: \(weatherDescription)")

        DispatchQueue.main.async {
          print("no error in parsing weather data!")
          if let delegate = self.delegate {
            let weatherData: WeatherData = WeatherData(shortNotes: weatherDescription, fDegrees: temperature)
            delegate.weatherManager(self, didUpdateWeather: [weatherData])
          }
        }
      } catch {
        print("Error in accessing Weather Service")
        if let delegate = self.delegate {
          delegate.weatherManager(self, didFailWithError: WeatherError.generic)
        }
        return
      }
    } // end shared.dataTask
    task.resume()
  }

}
