//
//  JournalEntryViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/27/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalEntryViewController: UIViewController {

  @IBOutlet var bodyOfWaterLabel: UILabel!
  @IBOutlet var addressLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet var timeIntervalLabel: UILabel!
  @IBOutlet var weatherLabel: UILabel!
  @IBOutlet var additionalNotesLabel: UILabel!
  
  var journalEntryViewModel: JournalEntryViewModel?
  var photos: [UIImage]?

  override func viewDidLoad() {
    super.viewDidLoad()
    displayValues()
  }

  private func displayValues() {
    guard let journalEntryViewModel = journalEntryViewModel else {
      return
    }

    // if there is a journal entry, it will have at the very least
    // date and time. Everything else is optional
    dateLabel.text = journalEntryViewModel.startDateDisplay()
    timeIntervalLabel.text = journalEntryViewModel.timeIntervalDisplay()

    if let bodyOfWater = journalEntryViewModel.bodyOfWaterDisplay() {
      bodyOfWaterLabel.text = bodyOfWater
    }

    if let address = journalEntryViewModel.addressDisplay() {
      addressLabel.text = address
    }

    if let photos = journalEntryViewModel.photoValues() {
      self.photos = photos
    }

    if let weatherText = journalEntryViewModel.weatherTemperatureWithUnitNotesDisplay() {
      weatherLabel.text = weatherText
    }

    if let notes = journalEntryViewModel.entryNotesDisplay() {
      additionalNotesLabel.text = notes
    }

  }
  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    if segue.identifier == "editEntry" {
      let navigationController = segue.destination as! UINavigationController
      let editEntryVC = navigationController.viewControllers[0] as! JournalEditorViewController
      editEntryVC.showDelete = true
      editEntryVC.journalEntryViewModel = journalEntryViewModel
    }

    if segue.identifier == "showScrollablePhotos" {
      let photoScrollVC = segue.destination as! JournalPhotoScrollViewController
      photoScrollVC.albumEditable = false
      if let photos = journalEntryViewModel?.photoValues() {
        photoScrollVC.photos = photos
      }
      print("coming from JournalEntryViewController, setting albumEditable to: \(photoScrollVC.albumEditable)")
    }
  }


}
