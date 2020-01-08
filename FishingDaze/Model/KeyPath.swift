//
//  ForKeyPathEnums.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/25/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

enum KeyPath: String {
  // for Entry
  case creationDateTime
  case startDateTime
  case endDateTime
  // Entry relationships
  case location

  // for Location
  case address
  case bodyOfWater
  case latitude
  case longitude
  // Location relationships
  case entry
  case weather

  // for Weather
  case description
  case FDegrees
}
