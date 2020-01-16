//
//  JournalEntryTableViewCell.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 7/11/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalListTableViewCell: UITableViewCell {

  @IBOutlet weak var fishingDateLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

}
