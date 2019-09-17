//
//  Date+Extension.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 9/17/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation

extension Date {


    /// Convert Date objects into their string representations
    ///
    /// - Parameters:
    ///   - dateStyle: Specified date format (.none, .short, .medium, .long, .full)
    ///   - timeStyle: Specified date format (.none, .short, .medium, .long, .full)
    ///
    /// Default timeStyle is .none
    /// - Returns: A string representation of a Date object
    func string(dateStyle: DateFormatter.Style, timeStyle: DateFormatter.Style = .none) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = dateStyle
        dateFormatter.timeStyle = timeStyle
        dateFormatter.locale = Locale(identifier: "en_US")

        return dateFormatter.string(from: self)
    }
}
