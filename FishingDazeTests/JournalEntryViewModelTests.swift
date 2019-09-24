//
//  JournalEntryViewModelTests.swift
//  FishingDazeTests
//
//  Created by Vui Nguyen on 9/22/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import XCTest
@testable import FishingDaze

class JournalEntryViewModelTests: XCTestCase {

  var journalEntryViewModel: JournalEntryViewModel!

  let creationDateTimeString = "2019-09-17 22:51:20 +0000"
  let startDateTimeString = "2019-09-17 20:51:15 +0000"
  let endDateTimeString = "2019-09-18 00:51:15 +0000"

  let startDateString = "September 17, 2019"

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // create a new JournalEntryViewModel object here
    journalEntryViewModel = JournalEntryViewModel(creationDate: creationDateTimeString.date()!,
                                                  endDate: endDateTimeString.date()!, startDate: startDateTimeString.date()!)

  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testStartDateTime() {
    XCTAssertEqual(journalEntryViewModel.startDateTime(), startDateTimeString)
  }

  func testStartDate() {
    XCTAssertEqual(journalEntryViewModel.startDate(), startDateString)
  }
}
