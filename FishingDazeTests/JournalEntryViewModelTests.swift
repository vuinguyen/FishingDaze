//
//  JournalEntryViewModelTests.swift
//  FishingDazeTests
//
//  Created by Vui Nguyen on 9/22/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import XCTest
import CoreLocation
@testable import FishingDaze

class JournalEntryViewModelTests: XCTestCase {

  var journalEntryViewModel: JournalEntryViewModel!

  let startDateTimeString = "2019-09-17 20:51:15 +0000"
  let entryDateString = "2019-09-17 20:51:15 +0000"
  let endDateTimeString = "2019-09-18 00:51:15 +0000"

  let startDateString = "September 17, 2019"

  // Cottonwood Park
  let locationCottonwoodPark: CLLocation = CLLocation(latitude: CLLocationDegrees(floatLiteral: 39.680353),
                                                   longitude: CLLocationDegrees(floatLiteral:-105.118191))

  let cottonwoodParkAddress = "2060 S Oak St\nJefferson\n80227\nUnited States\n"
  
  let locationHawaii: CLLocation = CLLocation(latitude: CLLocationDegrees(floatLiteral: 21.28277780),
                                              longitude: CLLocationDegrees(floatLiteral:-157.82944440))

  let hawaiiAddress = "201–499 Launiu St\nWaikiki\nHonolulu\n96815\nUnited States\n"

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.

    // create a new JournalEntryViewModel object here
    journalEntryViewModel = JournalEntryViewModel()
    journalEntryViewModel.entryDate = entryDateString.date()
    journalEntryViewModel.startDateTime = startDateTimeString.date()
    journalEntryViewModel.endDateTime = endDateTimeString.date()
    journalEntryViewModel.save()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    JournalEntryViewModel.deleteJournalEntryViewModel(existingViewModel: journalEntryViewModel, UIcompletion: {
      // do nothing
    })  }

  func testStartDateTimeDisplay() {
    XCTAssertEqual(journalEntryViewModel.startDateTimeDisplay(), startDateTimeString)
  }

  func testStartDateDisplay() {
    XCTAssertEqual(journalEntryViewModel.startDateDisplay(), startDateString)
  }

  func testCottonwoodParkAddress() {
    let expectation = XCTestExpectation(description: "Cottonwood Park Address String")
    journalEntryViewModel.addressDisplay(locations: [locationCottonwoodPark]) { (address) in
      XCTAssertNotEqual(address, "")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3.0)
  }

  func testHawaiiAddress() {
    let expectation = XCTestExpectation(description: "Hawaii Address String")
    journalEntryViewModel.addressDisplay(locations: [locationHawaii]) { (address) in
      XCTAssertEqual(address, self.hawaiiAddress)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3.0)
  }
}
