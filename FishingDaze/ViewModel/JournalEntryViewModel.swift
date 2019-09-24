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

  static func saveJournalEntryViewModel(startDateTime: Date, endDateTime: Date) {
    
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
    //let ymd = myCalendar.dateComponents([.year, .month, .day], from: currentDate)
    //print(ymd)

    return (date, startTime, endTime)
  }
}
