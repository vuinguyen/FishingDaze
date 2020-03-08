//
//  NotesViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 3/7/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData

class NoteViewModel {
  private let managedContext = PersistenceManager.shared.managedContext!
  var text: String?

  var entryModel: Entry?
  var noteModel: Note?  // Notes in Core Data model

  init() {

  }

  init(entryModel: Entry) {
    // add to Core Data
    let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
    noteModel = NSManagedObject(entity: entity, insertInto: managedContext) as? Note
    noteModel?.entry = entryModel
    self.entryModel = entryModel
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }


  // TODO: fetch
  static func fetchNotesViewModel(entryModel: Entry?) -> NoteViewModel? {
    var notesViewModel: NoteViewModel?

    guard let entryModel = entryModel else {
      return notesViewModel
    }

    do {
      let fetchRequest:NSFetchRequest<Note> = Note.fetchRequest()
    

    } catch let error as NSError {
      print("Could not fetch or save from context. \(error), \(error.userInfo)")
    }
    return notesViewModel
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
extension NoteViewModel: CoreDataFunctions {
  func save() {


  }
}
