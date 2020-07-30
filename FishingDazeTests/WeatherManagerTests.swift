//
//  WeatherManagerTests.swift
//  FishingDazeTests
//
//  Created by Vui Nguyen on 1/3/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import XCTest
import CoreLocation
@testable import FishingDaze



class WeatherManagerTests: XCTestCase, WeatherAPIManagerDelegate {
    var weatherManager: WeatherAPIManager!
    var journalEntryViewModel: JournalEntryViewModel!
    
    // Coordinate for Cottonwood Park
    var latitude: Double = 39.680353
    var longitude: Double = -105.118191
    
    let startDateTimeString = "2019-08-17 20:51:15 +0000"
    let entryDateString = "2019-08-17 20:51:15 +0000"
    let endDateTimeString = "2019-08-18 00:51:15 +0000"
    
   
    func weatherManager(_ manager: WeatherAPIManager, didUpdateWeather weatherData: [WeatherData]) {
        print("do we ever get here")
        
        
        journalEntryViewModel.weatherDisplay(weatherDataPoints: weatherData) { (temperature, notes) in
            print("temperature is: \(temperature ?? "")")
            self.journalEntryViewModel.temperature = temperature
            
            print("notes is: \(notes ?? "")")
            self.journalEntryViewModel.weatherNotes = notes
            
            self.journalEntryViewModel.save()
        }
        
    }
    
    func weatherManager(_ manager: WeatherAPIManager, didFailWithError error: Error) {
        print("Error: \(error)")
    }
  
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        journalEntryViewModel = JournalEntryViewModel()
        journalEntryViewModel.entryDate = entryDateString.date()
        journalEntryViewModel.startDateTime = startDateTimeString.date()
        journalEntryViewModel.endDateTime = endDateTimeString.date()
        journalEntryViewModel.save()
        
        weatherManager = WeatherAPIManager()
        weatherManager.delegate = self
        weatherManager.latitude = latitude
        weatherManager.longitude = longitude
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        weatherManager = nil
        JournalEntryViewModel.deleteJournalEntryViewModel(existingViewModel: journalEntryViewModel, UIcompletion: {
          // do nothing
            print("This journalViewModel deleted")
        })
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        weatherManager.requestWeather()
        print(journalEntryViewModel.weatherNotesDisplay() ?? "no weather notes displayed")
        print(journalEntryViewModel.latLongValues() ?? "no lat long")
    }
    
    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
 */

}
