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

    /*
    getCoordinates()
    guard let latitude = latitude,
      let longitude = longitude else {
        print("can't call weather API without getting location first")
        return
    }

    print("Found latitude is: \(latitude)")
    print("Found longitude is: \(longitude)")
 */

    if let weatherManager = weatherManager {
      weatherManager.requestWeather()
    }
 
  }

  func getCoordinates() {
    // first, check for existing latitude and longitude
    if let _ = latitude, let _ = longitude {
      print("getCoordinates: got it here 1st")
      return
    }

    // then, check for address in textfield
    if addressTextField.hasText {
      // geocode the address into coordinates

      // we should wrap all of this in a
      // journalEntryViewModel.weatherDisplay(locationString, completionHandler)
      let geocoder = CLGeocoder()
      geocoder.geocodeAddressString(addressTextField.text!) { (placemarks, error) in
          if error == nil {
              if let placemark = placemarks?[0] {
                  let location = placemark.location!

                  //completionHandler(location.coordinate, nil)
               // return (location.coordinate.latitude, location.coordinate.longitude)
                self.latitude = location.coordinate.latitude
                self.longitude = location.coordinate.longitude
                print("getCoordinates: got it here 2nd")
              }
          }

         // completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
      }



    } else {
      // call geolocation
      if let locationManager = locationManager {
        locationManager.requestLocation()
      }
      print("getCoordinates: got it here 3rd")
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

    if let latitude = latitude, let longitude = longitude {
      journalEntryViewModel?.latitude = latitude
      journalEntryViewModel?.longitude = longitude
    }

    journalEntryViewModel?.save()

    self.performSegue(withIdentifier: "ReturnToJournalListSegue", sender: nil)
  }

  var showDelete = false
  var journalEntryViewModel: JournalEntryViewModel?
  var locationManager: CLLocationManager?
  var weatherManager: WeatherAPIManager?

  var latitude: Double?
  var longitude: Double?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem

    bodyOfWaterTextField.delegate = self
    addressTextField.delegate = self
    weatherTemperatureField.delegate = self
    weatherDescriptionField.delegate = self

    loadInitialValues()

    showHideDelete()

    locationManager = CLLocationManager()
    if let locationManager = locationManager {
      locationManager.requestWhenInUseAuthorization()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    weatherManager = WeatherAPIManager()
    if let weatherManager = weatherManager {
      weatherManager.delegate = self
    }
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

    guard let (latitude, longitude) = entryViewModel.latLongValues() else {
      return
    }

    self.latitude = latitude
    self.longitude = longitude
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

// MARK: UITextFieldDelegate
extension JournalEditorViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

}

// MARK: CLLocationManagerDelegate
extension JournalEditorViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if journalEntryViewModel == nil {
      journalEntryViewModel = JournalEntryViewModel()
    }

    // how do we know that we need to display the address or display the weather?
    journalEntryViewModel?.addressDisplay(locations: locations, UIcompletion: { (address) in
      self.addressTextField.text = address
      guard let location = locations[0] as CLLocation? else {
        return
      }
      self.latitude = location.coordinate.latitude
      self.longitude = location.coordinate.longitude
    })
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("we got an error with location services: \(error.localizedDescription)")

    // display error in an alert box here ....
    // maybe display a message that says turn on location services and try again
  }
}

// MARK: WeatherAPIManagerDelegate
extension JournalEditorViewController: WeatherAPIManagerDelegate {
  func weatherManager(_ manager: WeatherAPIManager, didUpdateWeather weatherData: [WeatherData]) {
    print("Got weather data, yo!")

  }

  func weatherManager(_ manager: WeatherAPIManager, didFailWithError error: Error) {
    print("got an error, yo!")
  }
}
