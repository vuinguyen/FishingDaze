//
//  JournalEntry.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 7/11/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

struct Location {
  var bodyOfWater: String?
  var address: String
  var latitude: Double
  var longitude: Double
}

struct JournalEntryModel {
  var creationDateTime: Date
  var endDateTime: Date
  var startDateTime: Date
  var location: Location?

  init(creationDateTime: Date, endDateTime: Date, startDateTime: Date) {
    self.creationDateTime = creationDateTime
    self.endDateTime = endDateTime
    self.startDateTime = startDateTime
  }
}
