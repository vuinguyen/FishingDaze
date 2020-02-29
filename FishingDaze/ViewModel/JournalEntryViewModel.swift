//
//  JournalEntryViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/22/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class JournalEntryViewModel {
  private let entryModel: Entry?
  private let managedContext = PersistenceManager.shared.managedContext!
  private var locationViewModel: LocationViewModel?
  private var weatherViewModel: WeatherViewModel?
  private var photoViewModel: PhotoViewModel?

  // We have these attributes here to allow the user to
  // pass the data that they want to save to Core Data directly
  // using "simple Swift objects"
  // but they must call the display functions to display
  // the data to the view.

  // from Entry
  var entryDate: Date?
  var endDateTime: Date?
  var startDateTime: Date?

  // from Location
  var address: String?
  var bodyOfWater: String?
  var latitude: Double?
  var longitude: Double?

  // from Weather
  var weatherNotes: String?

  // this is a computed property, which gets set when temperature is set
  private lazy var fDegrees: Double? = { [weak self] in
    var temp: Double?
    if let tempString = self?.temperature {
      temp = Double(tempString)
    }
    return temp
  }()

  var temperature: String?

  // from Photo
  var images: [UIImage]?
  //var photoDictionary: [UIImage:Photo]?

  init() {
    let entity =
      NSEntityDescription.entity(forEntityName: "Entry",
                                 in: managedContext)!

      entryModel = NSManagedObject(entity: entity,
                                 insertInto: managedContext) as? Entry

    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save to Core Data. \(error), \(error.userInfo)")
    }
  }

  init(entryModel: Entry) {
    self.entryModel = entryModel
  }

  func startDateTimeDisplay() -> String {
    guard let entryModel = entryModel,
          let startDateTime =  entryModel.startDateTime?.description else {
      return Date().description
    }
    return startDateTime
  }

  func startDateDisplay() -> String {
    guard let entryModel = entryModel,
          let startDate = entryModel.startDateTime else {
      return Date().description
    }
    return startDate.string(dateStyle: .long)
  }

  // to be used when location is not added to Core Data yet
  func addressDisplay(locations: [CLLocation],  UIcompletion: ((String) -> Void)?) -> Void {

    guard let location = locations.first else {
        return
    }

    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel(entryModel: entryModel)
    }

    locationViewModel?.entryModel = entryModel
    locationViewModel?.clLocation = location
    locationViewModel?.displayAddressinView(UIcompletion: UIcompletion)
  }

  // to be used when location is already in Core Data
  func addressDisplay() -> String? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    return locationViewModel?.addressDisplay()
  }

  func bodyOfWaterDisplay() -> String? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    return locationViewModel?.bodyOfWaterDisplay()
  }

  // to be used when Weather is in Core Data
  func weatherTemperatureDisplay() -> String? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    if weatherViewModel == nil {
      weatherViewModel = WeatherViewModel.fetchWeatherViewModel(locationModel: locationViewModel?.locationModel)
    }

    return weatherViewModel?.temperatureDisplay()
  }

  // to be used when Weather is in Core Data
  func weatherNotesDisplay() -> String? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    if weatherViewModel == nil {
      weatherViewModel = WeatherViewModel.fetchWeatherViewModel(locationModel: locationViewModel?.locationModel)
    }

    return weatherViewModel?.notesDisplay()
  }


  // To be used when Weather is not yet in Core Data
  // NOTE: We are making an assumption that the locationViewModel should exist
  // before we can make a weatherViewModel
  func weatherDisplay(weatherDataPoints: [WeatherData], UIcompletion: ((String?, String?) -> Void)?) -> Void {
    guard let weatherData = weatherDataPoints.first else {
      return
    }

    if weatherViewModel == nil,
      let locationViewModel = locationViewModel,
      let locationModel = locationViewModel.locationModel {
      weatherViewModel = WeatherViewModel(locationModel: locationModel)
    }

    weatherViewModel?.weatherData = weatherData
    weatherViewModel?.displayWeatherinView(UIcompletion: UIcompletion)
  }

  func latLongValues() -> (Double, Double)? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    return locationViewModel?.latLongValues()
  }

  // Photo helper functions, to be used when Photo is already in Core Data
  func photoValues() -> [UIImage]? {
    if photoViewModel == nil,
     let entryModel = entryModel  {
      photoViewModel = PhotoViewModel.fetchPhotoViewModel(entryModel: entryModel)
    }
    return photoViewModel?.photoImages()
  }

  /*
  func photoDictionaryValues() -> [UIImage:Photo]? {
    if photoViewModel == nil,
     let entryModel = entryModel  {
      photoViewModel = PhotoViewModel.fetchPhotoViewModel(entryModel: entryModel)
    }
    return photoViewModel?.photoDictionary()
  }
 */


  static func fetchJournalEntryViewModels() -> [JournalEntryViewModel] {
    var viewModels: [JournalEntryViewModel] = []
    let managedContext = PersistenceManager.shared.managedContext!

    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
      fetchRequest.relationshipKeyPathsForPrefetching = [KeyPath.location.rawValue]
      let entries = try managedContext.fetch(fetchRequest)
      for entry in entries {
        if let endDateTime = entry.value(forKeyPath: KeyPath.endDateTime.rawValue ) as? Date,
          let startDateTime = entry.value(forKeyPath: KeyPath.startDateTime.rawValue) as? Date,
          let creationDateTime = entry.value(forKeyPath: KeyPath.creationDateTime.rawValue) as? Date {

          let viewModel = JournalEntryViewModel(entryModel: entry)
          viewModels.append(viewModel)

          print("loaded creationDateTime: \(creationDateTime)")
          print("loaded endDateTime: \(endDateTime)")
          print("loaded startDateTime: \(startDateTime)\n")
        }
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

    return viewModels
  }

  func fetch() {
    if entryModel == nil {
      print("we have an error with retrieving the Entry model!")
      return
    }
    fetchLocation()
    fetchWeather()
    fetchPhoto()
  }

  // we already grabbed the attributes for Entry earlier, so now we just need to grab
  // the Location data for this Entry
  private func fetchLocation() {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }
  }

  private func fetchWeather() {
    if weatherViewModel == nil,
      let locationViewModel = locationViewModel,
      let locationModel = locationViewModel.locationModel {
      weatherViewModel = WeatherViewModel.fetchWeatherViewModel(locationModel: locationModel)
    }
  }

  // TODO:
  private func fetchPhoto() {
    if photoViewModel == nil,
      let entryModel = entryModel {
      photoViewModel = PhotoViewModel.fetchPhotoViewModel(entryModel: entryModel)
    }
  }

  // TODO:
  func cancelChanges() {
    if managedContext.hasChanges {
      managedContext.rollback()
      print("rolled back changes to the context")
    }
  }

  private func saveEntry() {
    // we set values to the EntryModel here
    guard let entryModel = entryModel,
      let entryDate = entryDate,
      let startDateTime = startDateTime,
      let endDateTime = endDateTime else {
        print("error saving Entry")
        return
    }

      // this is where we grab values from the pickers and save them somewhere
      let oldStartTime = startDateTime
      let oldEndTime   = endDateTime
      // if the user modified the day picker, make sure that's reflected in the startTime and endTime date
      let myCalendar = Calendar(identifier: .gregorian)

      guard let updatedStartTime = myCalendar.date(bySettingHour: myCalendar.component(.hour, from: oldStartTime),
                                                   minute: myCalendar.component(.minute, from: oldStartTime),
                                                   second: myCalendar.component(.second, from: oldStartTime), of: entryDate) else { return }

      guard let updatedEndTime = myCalendar.date(bySettingHour: myCalendar.component(.hour, from: oldEndTime),
                                                 minute: myCalendar.component(.minute, from: oldEndTime),
                                                 second: myCalendar.component(.second, from: oldEndTime), of: entryDate) else { return }

      entryModel.endDateTime = updatedEndTime
      entryModel.startDateTime = updatedStartTime

      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save to Core Data. \(error), \(error.userInfo)")
      }
  }

  private func saveLocation() {
    guard let address = address else {
      return
    }

    if locationViewModel == nil,
       let entryModel = entryModel {
      locationViewModel = LocationViewModel(entryModel: entryModel)
    }

    locationViewModel?.address = address

    if let bodyOfWater = bodyOfWater {
      locationViewModel?.bodyOfWater = bodyOfWater
    }

    if let latitude = latitude, let longitude = longitude {
      locationViewModel?.latitude = latitude
      locationViewModel?.longitude = longitude
    }
    locationViewModel?.save()
  }

  private func saveWeather() {
    guard let fDegrees = fDegrees else {
      return
    }

    if weatherViewModel == nil,
      let locationViewModel = locationViewModel,
      let locationModel = locationViewModel.locationModel {
      weatherViewModel = WeatherViewModel(locationModel: locationModel)
    }

    weatherViewModel?.fDegrees = fDegrees

    if let shortNotes = weatherNotes {
      weatherViewModel?.shortNotes = shortNotes
    }
    weatherViewModel?.save()
  }

  // TODO
  private func savePhoto() {
    guard let images = images else {
      return
    }

    if photoViewModel == nil,
      let entryModel = entryModel {
      photoViewModel = PhotoViewModel(entryModel: entryModel, images: images)
    }

    photoViewModel?.images = images

    /*
    if let photoDict = photoDictionary {
      photoViewModel?.photoDict = photoDict
    }
 */
    photoViewModel?.save()
  }


  static func deleteJournalEntryViewModel(existingViewModel: JournalEntryViewModel?, UIcompletion:  @escaping () -> Void) {
    // find journal entry in Core Data and delete from Core Data
    let managedContext = PersistenceManager.shared.managedContext!

    findEntryByCreationDate(journalEntryViewModel: existingViewModel, completion: { (journalEntryToDelete, error) in
      guard let entry = journalEntryToDelete else {
        print("couldn't find entry to delete!")
        return
      }

      do {
          managedContext.delete(entry)
          try managedContext.save()
          UIcompletion()
      } catch let error as NSError {
        print("Could not save delete. \(error), \(error.userInfo)")
      }
    })
  }



  private static func findEntryByCreationDate(journalEntryViewModel: JournalEntryViewModel?, completion: @escaping (Entry?, Error?) -> Void) {
    guard let journalEntryViewModel = journalEntryViewModel,
          let entryModel = journalEntryViewModel.entryModel else {
      print("journalEntryViewModel not valid")
      return
    }

    let managedContext = PersistenceManager.shared.managedContext!

    let creationDatePredicate = NSPredicate(format: "creationDateTime = %@", entryModel.creationDateTime! as NSDate)

    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
      fetchRequest.relationshipKeyPathsForPrefetching = [KeyPath.location.rawValue]
      let entries = try managedContext.fetch(fetchRequest)
      let entriesFound = (entries as NSArray).filtered(using: creationDatePredicate) as! [NSManagedObject]
      if entriesFound.count >= 1 {

        if let entryFound = entriesFound[0] as? Entry {
          DispatchQueue.main.async {
            completion(entryFound, nil)
          }
        }
      }
    } catch let error as NSError {

      print("Could not fetch or save from context. \(error), \(error.userInfo)")
      completion(nil, error)
    }
  }
  
  static func setDefaultTimes(existingViewModel: JournalEntryViewModel?) -> (date: Date, startTime: Date, endTime: Date) {
      var date = Date()
      var startTime = Date()
      var endTime = Date()

      if let viewModel = existingViewModel {
        let model = viewModel.entryModel
        date = model?.startDateTime ?? Date()
        startTime = model?.startDateTime ?? Date()
        endTime = model?.endDateTime ?? Date()
      } else {
        let origStartTime = startTime
        // make the updated start time be 2 hours before the current time
        let timeInterval = TimeInterval(60*60*2)
        let updatedStartTime = origStartTime.addingTimeInterval(-timeInterval)
        startTime = updatedStartTime
      }

      //let myCalendar = Calendar(identifier: .gregorian)
      //let ymd = myCalendar.dateComponents([.year, .month, .day], from: date)
      //print(ymd)

      return (date, startTime, endTime)
    }

}

extension JournalEntryViewModel: CoreDataFunctions {
  func save() {
    saveEntry()
    saveLocation()
    saveWeather()
    savePhoto()
  }
}

extension JournalEntryViewModel: PhotoViewModelProtocol {
  func addPhotoSaveChange(photoToAdd: UIImage) {
    // TODO
    // Here we call PhotoViewModel function to do it's magic!
  }

  func deletePhotoSaveChange(photoToDelete: UIImage) {
    // TODO
    // Here we call PhotoViewModel function to do it's magic!
  }
}
