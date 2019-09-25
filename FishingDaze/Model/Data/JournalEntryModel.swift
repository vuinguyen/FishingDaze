//
//  JournalEntry.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 7/11/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

struct JournalEntryModel {
  var creationDateTime: Date
  var endDateTime: Date
  var startDateTime: Date

  init(creationDateTime: Date, endDateTime: Date, startDateTime: Date) {
    self.creationDateTime = creationDateTime
    self.endDateTime = endDateTime
    self.startDateTime = startDateTime
  }
}
