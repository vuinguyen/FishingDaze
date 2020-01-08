//
//  Entry+Extension.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 10/10/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import Foundation
import CoreData

extension Entry {
  public override func awakeFromInsert() {
    super.awakeFromInsert()
    creationDateTime = Date()
  }
}
