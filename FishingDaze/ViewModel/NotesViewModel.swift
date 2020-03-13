//
//  NotesViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 3/7/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData

class NotesViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var text: String?

  var entryModel: Entry?
  var notesModel: Notes?  // Note in Core Data model

  init() {

  }

  init(entryModel: Entry) {
    // add to Core Data
    let entity = NSEntityDescription.entity(forEntityName: "Notes", in: managedContext)!
    notesModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Notes
    notesModel?.entry = entryModel
    self.entryModel = entryModel
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }

  static func fetchNotesViewModel(entryModel: Entry?) -> NotesViewModel? {
    var notesViewModel: NotesViewModel?

    guard let entryModel = entryModel else {
      return notesViewModel
    }

    let managedContext = PersistenceManager.shared.managedContext!
    let entryPredicate = NSPredicate(format: "entry == %@", entryModel)

    do {
      let fetchRequest:NSFetchRequest<Notes> = Notes.fetchRequest()
      let multipleNotes = try managedContext.fetch(fetchRequest)
      let multipleNotesFound = (multipleNotes as NSArray).filtered(using: entryPredicate) as! [NSManagedObject]

      if multipleNotesFound.count >= 1 {
        if let notesFound = multipleNotesFound[0] as? Notes {
          notesViewModel = NotesViewModel()
          notesViewModel?.entryModel = entryModel
          notesViewModel?.notesModel = notesFound
        }
      }

    } catch let error as NSError {
      print("Could not fetch or save from context. \(error), \(error.userInfo)")
    }
    return notesViewModel
  }

  func notesDisplay() -> String? {
    guard let notes = notesModel,
      let text = notes.text else {
        return ""
    }

    return text
  }
}

extension NotesViewModel: CoreDataFunctions {
  func save() {
    guard let notes = notesModel else {
      return
    }

    if let text = text {
      notes.text = text
    }

    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}
