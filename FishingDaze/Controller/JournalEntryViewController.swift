//
//  JournalEntryViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/27/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalEntryViewController: UIViewController {

  @IBOutlet weak var dateLabel: UILabel!

  var journalEntry: JournalEntryModel?
  var journalEntryViewModel: JournalEntryViewModel?

  override func viewDidLoad() {
    super.viewDidLoad()

    if let journalEntry = journalEntry {
      dateLabel.text = journalEntry.startDate.description
    }

    if let journalEntryViewModel = journalEntryViewModel {
      dateLabel.text = journalEntryViewModel.startDateString()
    }
  }


  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    if segue.identifier == "editEntry" {
      let navigationController = segue.destination as! UINavigationController
      let entryVC = navigationController.viewControllers[0] as! JournalEditorViewController
      entryVC.showDelete = true
      entryVC.journalEntry = journalEntry
      entryVC.journalEntryViewModel = journalEntryViewModel
    }
  }


}
