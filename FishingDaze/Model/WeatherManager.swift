//
//  WeatherAPIManager.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/2/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {

}

let city = "Raleigh,NC"
let units = "I"

let exampleURL = "https://api.weatherbit.io/v2.0/current?city=Raleigh,NC&key=API_KEY"

class WeatherManager {

  let currentWeatherURL = "https://api.weatherbit.io/v2.0/current?" +
    "key=\(APIKeys.WeatherBitIOKey)" +
    "&city=\(city)" +
    "&units=\(units)"

  func requestWeather() {
    startLoad()

  }

  func startLoad() {
    let url = URL(string: currentWeatherURL)!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
      if let error = error {
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

        guard let forecast = firstData[0] as? [String: AnyObject],
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
          //self.webView.loadHTMLString(string, baseURL: url)
          print("no error in parsing!")
        }
      } catch {
        print("error yo!")
        return
      }
    } // end shared.dataTask
    task.resume()
  }

}
