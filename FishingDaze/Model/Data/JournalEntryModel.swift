//
//  JournalEntry.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 7/11/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

struct JournalEntryModel {
  var creationDate: Date
  var endDate: Date
  var startDate: Date

  init(creationDate: Date, endDate: Date, startDate: Date) {
    self.creationDate = creationDate
    self.endDate = endDate
    self.startDate = startDate
  }
}
