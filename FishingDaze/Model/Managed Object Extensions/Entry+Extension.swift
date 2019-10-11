//
//  Entry+Extension.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 10/10/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData

extension Entry: CoreDataSaving {
  func save() {
    let managedContext = PersistenceManager.shared.managedContext!
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }

  public override func awakeFromInsert() {
    super.awakeFromInsert()
    creationDateTime = Date()
  }

  /*
  func save(startDateTime: Date, endDateTime: Date) {
    let managedContext = PersistenceManager.shared.managedContext!

    setValue(startDateTime, forKeyPath: KeyPath.startDateTime.rawValue)
    setValue(endDateTime, forKeyPath: KeyPath.endDateTime.rawValue)
    do {
      try managedContext.save()
      print("Added entry, startTime is: \(String(describing: startDateTime))")
      print("Added entry, endTime is: \(String(describing: endDateTime))\n")
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }

    // self.save()
  }
 */
}
