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

// will this protocol be necessary?
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
      if error != nil {
        print("yo, we have an error here!")
        return
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print("yo, we have a server error here!")
          return
      }

      guard let data = data else {
        print("couldn't get data! :(")
        return
      }
      print("data is: \(data)")

      do {
        // let's parse some data here!
        // Note: I didn't use JSON Decoding here because the structure of the returned JSON
        // object was really complicated and wasn't worth the trouble to write Decoding classes
        // in order to grab a couple pieces of data, so JSON Serialization was an easier solution

         guard let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
          print("cannot serialize json!")
          return
         }
         //print(resultsDictionary)


        guard let count = resultsDictionary["count"] as? Int else {
          print("cannot get count")
          return
        }
        print("Int: \(count)")

        guard let firstData = resultsDictionary["data"] as? [[String: AnyObject]] else {
          print("cannot get forecast")
          return
        }
        print("forecast is: \(firstData[0])")

        guard let forecast = firstData[0] as [String: AnyObject]?,
          let temperature = forecast["temp"] as? Double else {
          print("cannot get temperature")
          return
        }
        print("temperature is: \(temperature)")

        guard let weather = forecast["weather"] as? [String: AnyObject],
          let weatherDescription = weather["description"] as? String else {
            print("cannot get weather description")
            return
        }
        print("weather description is: \(weatherDescription)")

        DispatchQueue.main.async {
          print("no error in parsing!")
          if let delegate = self.delegate {
            let weatherData: WeatherData = WeatherData(shortNotes: weatherDescription, fDegrees: temperature)
            delegate.weatherManager(self, didUpdateWeather: [weatherData])
          }
        }
      } catch {
        print("error yo!")
        return
      }
    } // end shared.dataTask
    task.resume()
  }

}
