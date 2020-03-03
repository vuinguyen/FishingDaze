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

  @IBOutlet var weatherTemperatureUnitLabel: UILabel!
  @IBOutlet var weatherTemperatureUnitControl: UISegmentedControl!

  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var startTimePicker: UIDatePicker!
  @IBOutlet weak var endTimePicker: UIDatePicker!

  @IBOutlet weak var deleteEntryButton: UIButton!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!

  @IBAction func selectTemperatureUnitDisplay(_ sender: Any) {
    print("Temperature Unit Display Selected!")
  }
  
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

    guard let latitude = latitude,
      let longitude = longitude else {
        return
    }

    if let weatherManager = weatherManager {
      weatherManager.latitude = latitude
      weatherManager.longitude = longitude
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
    journalEntryViewModel?.cancelChanges()
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

    if let temperature = weatherTemperatureField.text {
      journalEntryViewModel?.temperature = temperature
    }

    if let weatherNotes = weatherDescriptionField.text {
      journalEntryViewModel?.weatherNotes = weatherNotes
    }

    if let photos = photos {
      journalEntryViewModel?.images = photos
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

  //var photoImages: [UIImage]?
  var photos: [UIImage]?
  //var photoDictionary: [UIImage: Photo]?
  
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

    if let address = entryViewModel.addressDisplay() {
      addressTextField.text = address
    }

    if let bodyOfWater = entryViewModel.bodyOfWaterDisplay() {
      bodyOfWaterTextField.text = bodyOfWater
    }

    if let (latitude, longitude) = entryViewModel.latLongValues() {
      self.latitude = latitude
      self.longitude = longitude
    }

    if let temperature = entryViewModel.weatherTemperatureDisplay() {
      weatherTemperatureField.text = temperature
    }

    if let weatherNotes = entryViewModel.weatherNotesDisplay() {
      weatherDescriptionField.text = weatherNotes
    }

    if let photos = entryViewModel.photoValues() {
      self.photos = photos
    }
  }

  func showHideDelete() {
    deleteEntryButton.isHidden = showDelete == true ? false : true
    deleteEntryButton.isEnabled = showDelete == true ? true : false
  }

  // MARK: - Navigation

  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    // Get the new view controller using segue.destination.
    // Pass the selected object to the new view controller.
    if segue.identifier == "showScrollablePhotos" {
      let photoScrollVC = segue.destination as! JournalPhotoScrollViewController
      photoScrollVC.albumEditable = true
      //if let photos = photos {
      if let photos = journalEntryViewModel?.photoValues() {
        photoScrollVC.photos = photos
      }
      photoScrollVC.photoScrollDelegate = self
      print("coming from JournalEditorViewController, setting albumEditable to: \(photoScrollVC.albumEditable)")
    }
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

      // based on a flag, call weather here
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

    if journalEntryViewModel == nil {
      journalEntryViewModel = JournalEntryViewModel()
    }

    journalEntryViewModel?.weatherDisplay(weatherDataPoints: weatherData, UIcompletion: { (temperature, notes) in
      self.weatherDescriptionField.text = notes
      self.weatherTemperatureField.text = temperature
    })
  }

  func weatherManager(_ manager: WeatherAPIManager, didFailWithError error: Error) {
    print("got an error, yo!")
  }
}

extension JournalEditorViewController: PhotoScrollDelegate {
  func addPhoto(photoToAdd: UIImage, updatedPhotos: [UIImage]) {
    // update local photos
    self.photos = updatedPhotos

    // update photos in ViewModel
    journalEntryViewModel?.addPhotoToModel(photoToAdd: photoToAdd)
  }

  func deletePhoto(photoToDelete: UIImage, updatedPhotos: [UIImage]) {
    // update local photos
    self.photos = updatedPhotos

    // update photos in ViewModel
    journalEntryViewModel?.deletePhotoFromModel(photoToDelete: photoToDelete)
  }
}
