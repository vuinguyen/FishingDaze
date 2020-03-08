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
  var noteModel: Notes?  // Note in Core Data model

  init() {

  }

  init(entryModel: Entry) {
    // add to Core Data
    let entity = NSEntityDescription.entity(forEntityName: "Notes", in: managedContext)!
    noteModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Notes
    noteModel?.entry = entryModel
    self.entryModel = entryModel
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }


  // TODO: fetch
  static func fetchNotesViewModel(entryModel: Entry?) -> NotesViewModel? {
    var noteViewModel: NotesViewModel?

    guard let entryModel = entryModel else {
      return noteViewModel
    }

    do {
      let fetchRequest:NSFetchRequest<Notes> = Notes.fetchRequest()
    

    } catch let error as NSError {
      print("Could not fetch or save from context. \(error), \(error.userInfo)")
    }
    return noteViewModel
  }

  func notesDisplay() -> String? {
    guard let note = noteModel,
      let text = note.text else {
      return ""
    }

    return text
  }
}

//TODO
extension NotesViewModel: CoreDataFunctions {
  func save() {


  }
}
