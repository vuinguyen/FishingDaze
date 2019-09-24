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

  func saveJournalEntryViewModel() {

  }


}
