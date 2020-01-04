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

  // from Entry
  var entryDate: Date?
  var endDateTime: Date?
  var startDateTime: Date?

  // from Location
  var address: String?
  var bodyOfWater: String?
  var latitude: Double = 0.0
  var longitude: Double = 0.0

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

  func latLongValues() -> (Double, Double)? {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
    }

    return locationViewModel?.latLongValues()
  }

  static func fetchJournalEntryViewModels() -> [JournalEntryViewModel] {
    var viewModels: [JournalEntryViewModel] = []
    let managedContext = PersistenceManager.shared.managedContext!

    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
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
  }

  // we already grabbed the attributes for Entry earlier, so now we just need to grab
  // the Location data for this Entry
  private func fetchLocation() {
    if locationViewModel == nil,
       let entryModel = entryModel  {
      locationViewModel = LocationViewModel.fetchLocationViewModel(entryModel: entryModel)
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
    guard let address = address,
        let bodyOfWater = bodyOfWater else {
        return
    }

    if locationViewModel == nil,
       let entryModel = entryModel {
      locationViewModel = LocationViewModel(entryModel: entryModel)
    }

    locationViewModel?.address = address
    locationViewModel?.bodyOfWater = bodyOfWater
    locationViewModel?.latitude = latitude
    locationViewModel?.longitude = longitude
    locationViewModel?.save()
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
  }
}
