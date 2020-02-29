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

  var journalEntryViewModel: JournalEntryViewModel?
  /*
  lazy var photos: [UIImage] = { [weak self] in
  var images: [UIImage] = []
  ["testPhoto1", "testPhoto2", "testPhoto3"].forEach { imageName in
    if let image = UIImage(named: imageName) {
      images.append(image)
    }
  }

  return images
  }()
 */
  var photos: [UIImage]?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let journalEntryViewModel = journalEntryViewModel else {
      return
    }

    // if there is a journal entry, it will have at the very least
    // date and time. Everything else is optional
    dateLabel.text = journalEntryViewModel.startDateTimeDisplay()


    if let photos = journalEntryViewModel.photoValues() {
      self.photos = photos
    }

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    guard let journalEntryViewModel = journalEntryViewModel else {
      return
    }

    // if there is a journal entry, it will have at the very least
    // date and time. Everything else is optional
    dateLabel.text = journalEntryViewModel.startDateTimeDisplay()


    if let photos = journalEntryViewModel.photoValues() {
      self.photos = photos
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
