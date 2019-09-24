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
  //private var appDelegate: AppDelegate!
  //private var managedContext: NSManagedObjectContext!

  init(creationDate: Date, endDate: Date, startDate: Date) {
    journalEntryModel = JournalEntryModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
  }

  func startDateTime() -> String {
    return journalEntryModel.startDate.description
  }

  func startDate() -> String {
    return journalEntryModel.startDate.string(dateStyle: .long)
  }

  /*
   private static func setUpCoreData() {
   appDelegate = UIApplication.shared.delegate as? AppDelegate
   managedContext = appDelegate.persistentContainer.viewContext
   }
   */

  static func fetchJournalEntryViewModels() -> [JournalEntryViewModel] {
    var viewModels: [JournalEntryViewModel] = []
    //setUpCoreData()

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return viewModels
    }
    guard let managedContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext? else {
      return viewModels
    }

    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
      let entries = try managedContext.fetch(fetchRequest)
      for entry in entries {
        if let endDate = entry.value(forKeyPath: "endDate") as? Date,
          let startDate = entry.value(forKeyPath: "startDate") as? Date,
          let creationDate = entry.value(forKeyPath: "creationDate") as? Date {
          //let journalEntry = JournalEntryModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
          //journalEntries.append(journalEntry)

          let viewModel = JournalEntryViewModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
          viewModels.append(viewModel)

          print("loaded creationDate: \(creationDate)")
          print("loaded endDate: \(endDate)")
          print("loaded startDate: \(startDate)\n")
        }
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

    return viewModels
  }

  static func saveJournalEntryViewModel(date: Date, startDateTime: Date, endDateTime: Date, existingViewModel: JournalEntryViewModel?) {
    print("save changes!")

    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    guard let managedContext = appDelegate.persistentContainer.viewContext as NSManagedObjectContext? else {
      return 
    }

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

    // Save to Core Data if new entry
    /*
     if isExistingEntry == false {
     let entity =
     NSEntityDescription.entity(forEntityName: "Entry",
     in: managedContext)!

     let entry = NSManagedObject(entity: entity,
     insertInto: managedContext)

     let creationDate = Date()
     entry.setValue(updatedStartTime, forKeyPath: "startDate")
     entry.setValue(updatedEndTime, forKey: "endDate")
     entry.setValue(creationDate, forKey: "creationDate")
     do {
     try managedContext.save()
     print("Added entry, creationDate is: \(creationDate)")
     print("Added entry, startTime is: \(String(describing: updatedStartTime))")
     print("Added entry, endTime is: \(String(describing: updatedEndTime))\n")
     } catch let error as NSError {
     print("Could not save. \(error), \(error.userInfo)")
     }
     } else {
     */
    // save existing entry in Core Data
    if let viewModel = existingViewModel {
      // else search for entry by creationDate, edit entry in Core Data and then save!
      findEntryByCreationDate(journalEntryViewModel: viewModel, managedContext: managedContext, completion: { (journalEntryEdited, error) in
        // grab data from all the controls and save here!!
        guard let entry = journalEntryEdited else {
          print("could not find entry here")
          return
        }

        entry.setValue(updatedStartTime, forKeyPath: "startDate")
        entry.setValue(updatedEndTime, forKey: "endDate")
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

      let creationDate = Date()
      entry.setValue(updatedStartTime, forKeyPath: "startDate")
      entry.setValue(updatedEndTime, forKey: "endDate")
      entry.setValue(creationDate, forKey: "creationDate")
      do {
        try managedContext.save()
        print("Added entry, creationDate is: \(creationDate)")
        print("Added entry, startTime is: \(String(describing: updatedStartTime))")
        print("Added entry, endTime is: \(String(describing: updatedEndTime))\n")
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }

  }

  private static func findEntryByCreationDate(journalEntryViewModel: JournalEntryViewModel?, managedContext: NSManagedObjectContext, completion: @escaping (Entry?, Error?) -> Void) {
    guard let journalEntryViewModel = journalEntryViewModel else {
      return
    }

    let creationDatePredicate = NSPredicate(format: "creationDate = %@", journalEntryViewModel.journalEntryModel.creationDate as NSDate)

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
        date = model.startDate
        startTime = model.startDate
        endTime = model.endDate
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
