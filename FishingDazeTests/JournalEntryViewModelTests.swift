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

  let creationDateString = "2019-09-17 22:51:20 +0000"
  let startDateString = "2019-09-17 20:51:15 +0000"
  let endDateString = "2019-09-18 00:51:15 +0000"

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // create a new JournalEntryViewModel object here
    journalEntryViewModel = JournalEntryViewModel(creationDate: creationDateString.date()!,
                                                  endDate: endDateString.date()!, startDate: startDateString.date()!)

  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testStartDateString() {
    XCTAssertEqual(journalEntryViewModel.startDateString(), startDateString)
  }

  func testSaveJournalEntryViewModel() {
    
  }



}
