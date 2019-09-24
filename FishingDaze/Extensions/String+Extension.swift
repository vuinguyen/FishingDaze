//
//  String+Extension.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/23/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

extension String {
  func date() -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    dateFormatter.locale = Locale(identifier: "en_US")
    return dateFormatter.date(from: self) 
  }
}
