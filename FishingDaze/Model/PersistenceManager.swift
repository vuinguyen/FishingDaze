//
//  PersistenceManager.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/24/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class PersistenceManager {

  let managedContext: NSManagedObjectContext!
  static let shared = PersistenceManager()

  private init() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    self.managedContext = appDelegate?.persistentContainer.viewContext as NSManagedObjectContext?
  }
}
  

