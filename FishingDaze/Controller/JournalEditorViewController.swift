//
//  JournalEditorViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/27/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit
//import CoreData
import CoreLocation

class JournalEditorViewController: UITableViewController {
  @IBOutlet weak var bodyOfWaterTextField: UITextField!
  @IBOutlet weak var addressTextField: UITextField!

  @IBOutlet weak var weatherTemperatureField: UITextField!
  @IBOutlet weak var weatherDescriptionField: UITextField!

  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var startTimePicker: UIDatePicker!
  @IBOutlet weak var endTimePicker: UIDatePicker!

  @IBOutlet weak var deleteEntryButton: UIButton!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!
  
  @IBAction func getCurrentLocation(_ sender: Any) {
    print("get current location!")

    // this works only if geolocation is on
    if let locationManager = locationManager {
      locationManager.requestLocation()
    }
  }

  // Note: weather will be based on the location and end time
  @IBAction func getWeather(_ sender: Any) {
    print("get current weather based on location")

    if let weatherManager = weatherManager {
      weatherManager.requestWeather()
    }
  }

  @IBAction func deleteEntry(_ sender: Any) {
    print("we're going to delete an entry!")
    // Create the action buttons for the alert.
    let destroyAction = UIAlertAction(title: "Delete",
                                      style: .destructive) { (action) in

      JournalEntryViewModel.deleteJournalEntryViewModel(existingViewModel: self.journalEntryViewModel,
                                                        UIcompletion: {
                                                          self.performSegue(withIdentifier: "ReturnToJournalListSegue", sender: nil)
                                                        })
    }

    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .cancel) { (action) in
                                      // Respond to user selection of the action
    }

    let alert = UIAlertController(title: "Delete Journal Entry?",
                                  message: "",
                                  preferredStyle: .actionSheet)
    alert.addAction(destroyAction)
    alert.addAction(cancelAction)

    // On iPad, action sheets must be presented from a popover.
    alert.popoverPresentationController?.barButtonItem = saveBarButton

    self.present(alert, animated: true) {
      // The alert was presented
    }

  }

  @IBAction func cancelEditing(_ sender: Any) {
    self.performSegue(withIdentifier: "ReturnToJournalListSegue", sender: nil)
  }
  
  @IBAction func saveEdits(_ sender: Any) {
    if journalEntryViewModel == nil {
      journalEntryViewModel = JournalEntryViewModel()
    }

    journalEntryViewModel?.entryDate = datePicker.date
    journalEntryViewModel?.startDateTime = startTimePicker.date
    journalEntryViewModel?.endDateTime = endTimePicker.date

    // now, if the location entries are not empty, save them!
    if let address =  addressTextField.text {
      journalEntryViewModel?.address = address
    }

    if let bodyOfWater = bodyOfWaterTextField.text {
      journalEntryViewModel?.bodyOfWater = bodyOfWater
    }

    journalEntryViewModel?.save()

    self.performSegue(withIdentifier: "ReturnToJournalListSegue", sender: nil)
  }

  var showDelete = false
  var journalEntryViewModel: JournalEntryViewModel?
  var locationManager: CLLocationManager?
  var weatherManager: WeatherManager?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
    loadInitialValues()

    showHideDelete()

    locationManager = CLLocationManager()
    if let locationManager = locationManager {
      locationManager.requestWhenInUseAuthorization()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    weatherManager = WeatherManager()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }

  func loadInitialValues() {
    (datePicker.date, startTimePicker.date, endTimePicker.date) =
    JournalEntryViewModel.setDefaultTimes(existingViewModel: journalEntryViewModel)

    // if this is a new journal entry, there's nothing else to load
    guard let entryViewModel = journalEntryViewModel else {
      return
    }
    bodyOfWaterTextField.text = entryViewModel.bodyOfWaterDisplay()
    addressTextField.text = entryViewModel.addressDisplay()
  }

  func showHideDelete() {
    deleteEntryButton.isHidden = showDelete == true ? false : true
    deleteEntryButton.isEnabled = showDelete == true ? true : false
  }

  // MARK: TableViewDelegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

extension JournalEditorViewController: UITextFieldDelegate {

}

extension JournalEditorViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if journalEntryViewModel == nil {
      journalEntryViewModel = JournalEntryViewModel()
    }

    journalEntryViewModel?.addressDisplay(locations: locations, UIcompletion: { (address) in
      self.addressTextField.text = address
    })
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("we got an error: \(error.localizedDescription)")

    // display error in an alert box here ....
    // maybe display a message that says turn on location services and try again
  }
}
