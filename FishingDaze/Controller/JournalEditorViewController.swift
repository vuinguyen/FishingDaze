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

  @IBOutlet var notesTextView: UITextView!
  
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var startTimePicker: UIDatePicker!
  @IBOutlet weak var endTimePicker: UIDatePicker!

  @IBOutlet weak var deleteEntryButton: UIButton!
  @IBOutlet weak var saveBarButton: UIBarButtonItem!

  @IBAction func selectTemperatureUnitDisplay(_ sender: Any) {
    let temperatureUnit = weatherTemperatureUnitControl.selectedSegmentIndex == TempUnitControlSegment.fahreinhet.rawValue ?
                          TemperatureUnit.fahreinhet : TemperatureUnit.celsius
    JournalEntryViewModel.setWeatherTemperatureUnit(setToUnit: temperatureUnit)
    checkTemperatureUnitDisplay()
  }
  
  @IBAction func getCurrentLocation(_ sender: Any) {
    print("get current location!")
    activityIndicator.startAnimating()

    // this works only if geolocation is on
    if let locationManager = locationManager {
      locationManager.requestLocation()
    }
  }

  // Note: weather will be based on the location and end time
  @IBAction func getWeather(_ sender: Any) {
    print("get current weather based on location")
    activityIndicator.startAnimating()

    guard let latitude = latitude,
      let longitude = longitude else {
        let alert = UIAlertController(title: "Weather Service Error",
                                      message: "Can't access weather service without a Location. Click on Find Location button and try again",
                                      preferredStyle: .alert)
        // Create an action and lets name it Ok.
         let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
             // On Click we need to dismiss the alert controller.
            alert.dismiss(animated: true, completion: nil)
        }

        // Add the above created action to the Controller.
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        return
    }

    if let weatherManager = weatherManager {
      weatherManager.latitude = latitude
      weatherManager.longitude = longitude
      weatherManager.requestWeather()
    }
  }

  private func checkTemperatureUnitDisplay() {
    // set segment control
    weatherTemperatureUnitControl.selectedSegmentIndex = JournalEntryViewModel.getWeatherTemperatureUnit() == TemperatureUnit.fahreinhet ?
                                                        TempUnitControlSegment.fahreinhet.rawValue : TempUnitControlSegment.celsius.rawValue

    // display numerical temperature value
    if let temperature = journalEntryViewModel?.weatherTemperatureDisplay() {
      weatherTemperatureField.text = temperature
    }

    // display temperature unit
    weatherTemperatureUnitLabel.text = JournalEntryViewModel.weatherTemperatureUnitDisplay()
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

    // if notes isn't blank & notes isn't default text
    if notesTextView.text != "" && notesTextView.text != noteAreaDefaultText {
      journalEntryViewModel?.text = notesTextView.text
    }

    journalEntryViewModel?.save()

    self.performSegue(withIdentifier: "ReturnToJournalListSegue", sender: nil)
  }

  let noteAreaDefaultText = "Add Additional Notes Here"
  var showDelete = false
  var journalEntryViewModel: JournalEntryViewModel?
  var locationManager: CLLocationManager?
  var weatherManager: WeatherAPIManager?

  var latitude: Double?
  var longitude: Double?

  var photos: [UIImage]?
  var activityIndicator = UIActivityIndicatorView()

  enum TempUnitControlSegment: Int {
    case fahreinhet = 0
    case celsius = 1
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    setupActivityIndicator()
    setupDelegates()
    loadInitialValues()
    showHideDeleteButton()
    hideKeyboardWithDoneButton()

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

  func setupActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    activityIndicator.style = UIActivityIndicatorView.Style.gray
    activityIndicator.center = self.view.center
    activityIndicator.hidesWhenStopped = true
    self.view.addSubview(activityIndicator)
  }

  func setupDelegates() {
    bodyOfWaterTextField.delegate = self
    addressTextField.delegate = self
    weatherTemperatureField.delegate = self
    weatherDescriptionField.delegate = self
    notesTextView.delegate = self
  }

  func hideKeyboardWithDoneButton() {
    let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: view.frame.size.width, height: 30)))

    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))

    toolbar.setItems([flexSpace, doneButton], animated: false)

    bodyOfWaterTextField.inputAccessoryView = toolbar
    addressTextField.inputAccessoryView = toolbar

    weatherTemperatureField.inputAccessoryView = toolbar
    weatherDescriptionField.inputAccessoryView = toolbar

    notesTextView.inputAccessoryView = toolbar
  }

  @objc func doneButtonAction() {
    self.view.endEditing(true)
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

    checkTemperatureUnitDisplay()
    
    if let weatherNotes = entryViewModel.weatherNotesDisplay() {
      weatherDescriptionField.text = weatherNotes
    }

    if let photos = entryViewModel.photoValues() {
      self.photos = photos
    }

    if let entryNotes = entryViewModel.entryNotesDisplay() {
      notesTextView.text = entryNotes
    }
  }

  func showHideDeleteButton() {
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

// MARK: UITextViewDelegate
extension JournalEditorViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    if notesTextView.text == noteAreaDefaultText {
      notesTextView.text = ""
    }
  }
}

// MARK: CLLocationManagerDelegate
extension JournalEditorViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if journalEntryViewModel == nil {
      journalEntryViewModel = JournalEntryViewModel()
    }

    journalEntryViewModel?.addressDisplay(locations: locations, UIcompletion: { (address) in
      self.addressTextField.text = address
      guard let location = locations[0] as CLLocation? else {
        return
      }
      self.latitude = location.coordinate.latitude
      self.longitude = location.coordinate.longitude
    })

    activityIndicator.stopAnimating()
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    activityIndicator.stopAnimating()
    print("Location Service Error: \(error.localizedDescription)")

    let alert = UIAlertController(title: "Location Services Error", message: error.localizedDescription, preferredStyle: .alert)
    // Create an action and lets name it Ok.
     let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
         // On Click we need to dismiss the alert controller.
        alert.dismiss(animated: true, completion: nil)
    }
    // Add the above created action to the Controller.
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
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

    activityIndicator.stopAnimating()
  }

  func weatherManager(_ manager: WeatherAPIManager, didFailWithError error: Error) {
    activityIndicator.stopAnimating()

    print("Weather Service Error: \(error.localizedDescription)")

    let alert = UIAlertController(title: "Weather Services Error", message: error.localizedDescription, preferredStyle: .alert)
    // Create an action and lets name it Ok.
     let okAction = UIAlertAction(title: "Ok", style: .default) { (_) in
         // On Click we need to dismiss the alert controller.
        alert.dismiss(animated: true, completion: nil)
    }
    // Add the above created action to the Controller.
    alert.addAction(okAction)
    self.present(alert, animated: true, completion: nil)
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
