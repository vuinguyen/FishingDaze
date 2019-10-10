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

  let creationDateTimeString = "2019-09-17 22:51:20 +0000"
  let startDateTimeString = "2019-09-17 20:51:15 +0000"
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
    journalEntryViewModel = JournalEntryViewModel(creationDateTime: creationDateTimeString.date()!,
                                                  endDateTime: endDateTimeString.date()!, startDateTime: startDateTimeString.date()!)

  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    JournalEntryViewModel.deleteJournalEntryViewModel(existingViewModel: journalEntryViewModel, UIcompletion: {
      // do nothing
    })  }

  func testStartDateTime() {
    XCTAssertEqual(journalEntryViewModel.startDateTimeDisplay(), startDateTimeString)
  }

  func testStartDate() {
    XCTAssertEqual(journalEntryViewModel.startDate(), startDateString)
  }

  func testCottonwoodParkAddress() {
    let expectation = XCTestExpectation(description: "Hawaii Address String")
    JournalEntryViewModel.address(locations: [locationCottonwoodPark], existingViewModel: journalEntryViewModel) { (address) in
      XCTAssertNotEqual(address, "")

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3.0)
  }

  func testHawaiiAddress() {
    let expectation = XCTestExpectation(description: "Hawaii Address String")
    JournalEntryViewModel.address(locations: [locationHawaii], existingViewModel: journalEntryViewModel) { (address) in
      XCTAssertEqual(address, self.hawaiiAddress)

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 3.0)
  }
}
