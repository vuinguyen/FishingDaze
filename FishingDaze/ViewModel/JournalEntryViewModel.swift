//
//  JournalEntryViewModel.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/22/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

struct JournalEntryViewModel {
  private let journalEntryModel: JournalEntryModel

  init(creationDate: Date, endDate: Date, startDate: Date) {
    journalEntryModel = JournalEntryModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
  }

  func startDateString() -> String {
    return journalEntryModel.startDate.description
  }
}
