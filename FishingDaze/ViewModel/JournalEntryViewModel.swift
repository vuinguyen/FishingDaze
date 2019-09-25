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

struct JournalEntryViewModel {
  private let journalEntryModel: JournalEntryModel
  
  init(creationDateTime: Date, endDateTime: Date, startDateTime: Date) {
    journalEntryModel = JournalEntryModel(creationDateTime: creationDateTime, endDateTime: endDateTime, startDateTime: startDateTime)
  }

  func startDateTime() -> String {
    return journalEntryModel.startDateTime.description
  }

  func startDate() -> String {
    return journalEntryModel.startDateTime.string(dateStyle: .long)
  }

  static func fetchJournalEntryViewModels() -> [JournalEntryViewModel] {
    var viewModels: [JournalEntryViewModel] = []
    let managedContext = PersistenceManager.shared.managedContext!

    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
      let entries = try managedContext.fetch(fetchRequest)
      for entry in entries {
        if let endDateTime = entry.value(forKeyPath: "endDateTime") as? Date,
          let startDateTime = entry.value(forKeyPath: "startDateTime") as? Date,
          let creationDateTime = entry.value(forKeyPath: "creationDateTime") as? Date {
          //let journalEntry = JournalEntryModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
          //journalEntries.append(journalEntry)

          let viewModel = JournalEntryViewModel(creationDateTime: creationDateTime, endDateTime: endDateTime, startDateTime: startDateTime)
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

  static func saveJournalEntryViewModel(date: Date, startDateTime: Date, endDateTime: Date, existingViewModel: JournalEntryViewModel?) {
    print("save changes!")

    let managedContext = PersistenceManager.shared.managedContext!

    // this is where we grab values from the pickers and save them somewhere
    let oldStartTime = startDateTime
    let oldEndTime   = endDateTime
    // if the user modified the day picker, make sure that's reflected in the startTime and endTime date
    let myCalendar = Calendar(identifier: .gregorian)

    let updatedStartTime = myCalendar.date(bySettingHour: myCalendar.component(.hour, from: oldStartTime),
                                           minute: myCalendar.component(.minute, from: oldStartTime),
                                           second: myCalendar.component(.second, from: oldStartTime), of: date)

    let updatedEndTime = myCalendar.date(bySettingHour: myCalendar.component(.hour, from: oldEndTime),
                                         minute: myCalendar.component(.minute, from: oldEndTime),
                                         second: myCalendar.component(.second, from: oldEndTime), of: date)

    // save existing entry in Core Data
    if let viewModel = existingViewModel {
      // else search for entry by creationDate, edit entry in Core Data and then save!
      findEntryByCreationDate(journalEntryViewModel: viewModel, completion: { (journalEntryEdited, error) in
        // grab data from all the controls and save here!!
        guard let entry = journalEntryEdited else {
          print("could not find entry here")
          return
        }

        entry.setValue(updatedStartTime, forKeyPath: "startDateTime")
        entry.setValue(updatedEndTime, forKey: "endDateTime")
        do {
          try managedContext.save()
          print("Edited entry, startTime is: \(String(describing: updatedStartTime))")
          print("Edited entry, endTime is: \(String(describing: updatedEndTime))\n")
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }

      })
    } else {
      let entity =
        NSEntityDescription.entity(forEntityName: "Entry",
                                   in: managedContext)!

      let entry = NSManagedObject(entity: entity,
                                  insertInto: managedContext)

      let creationDateTime = Date()
      entry.setValue(updatedStartTime, forKeyPath: "startDateTime")
      entry.setValue(updatedEndTime, forKey: "endDateTime")
      entry.setValue(creationDateTime, forKey: "creationDateTime")
      do {
        try managedContext.save()
        print("Added entry, creationDate is: \(creationDateTime)")
        print("Added entry, startTime is: \(String(describing: updatedStartTime))")
        print("Added entry, endTime is: \(String(describing: updatedEndTime))\n")
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }

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
    guard let journalEntryViewModel = journalEntryViewModel else {
      print("journalEntryViewModel not valid")
      return
    }

    let managedContext = PersistenceManager.shared.managedContext!

    let creationDatePredicate = NSPredicate(format: "creationDateTime = %@", journalEntryViewModel.journalEntryModel.creationDateTime as NSDate)

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
        let model = viewModel.journalEntryModel
        date = model.startDateTime
        startTime = model.startDateTime
        endTime = model.endDateTime
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
