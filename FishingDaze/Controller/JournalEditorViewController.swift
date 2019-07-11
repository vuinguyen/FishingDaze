//
//  JournalEditorViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/27/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalEditorViewController: UITableViewController {
  @IBOutlet weak var waterLocationTextField: UITextField!
  @IBOutlet weak var moreLocationTextField: UITextField!
  
  @IBOutlet weak var datePicker: UIDatePicker!
  @IBOutlet weak var startTimePicker: UIDatePicker!
  @IBOutlet weak var endTimePicker: UIDatePicker!
  @IBOutlet weak var deleteEntryButton: UIButton!
  
  @IBOutlet weak var saveBarButton: UIBarButtonItem!
  
  @IBAction func deleteEntry(_ sender: Any) {
    print("we're going to delete an entry!")
    // Create the action buttons for the alert.
    let destroyAction = UIAlertAction(title: "Delete",
                                      style: .destructive) { (action) in
                                        // Respond to user selection of the action
    // delete from Core Data
    // unwind back to journal entry list
    self.performSegue(withIdentifier: "DeleteEntrySegue", sender: nil)
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
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func saveEdits(_ sender: Any) {
    // save to Core Data

    dismiss(animated: true, completion: saveStuff)
  }

  var showDelete = false

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem

    setDefaultTimes()
    showHideDelete()
  }

  func saveStuff() {
    print("save changes!")

    // this is where we grab values from the pickers and save them somewhere
    let startTime = startTimePicker.date
    let endTime   = endTimePicker.date

    print("startTime is: \(startTime)")
    print("endTime is: \(endTime)")
  }

  // this needs to go into a utility class
  func formatDate() {

  }

  func setDefaultTimes() {
    let origStartTime = startTimePicker.date
    // make the updated start time be 2 hours before the current time
    let timeInterval = TimeInterval(60*60*2)
    let updatedStartTime = origStartTime.addingTimeInterval(-timeInterval)
    startTimePicker.date = updatedStartTime
  }

  func showHideDelete() {
    deleteEntryButton.isHidden = showDelete == true ? false : true
    deleteEntryButton.isEnabled = showDelete == true ? true : false
  }
  // MARK: - Table view data source

  /*
   override func numberOfSections(in tableView: UITableView) -> Int {
   // #warning Incomplete implementation, return the number of sections
   return 0
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   // #warning Incomplete implementation, return the number of rows
   return 0
   }
   */
  /*
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

   // Configure the cell...

   return cell
   }
   */

  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */

  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */

  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

   }
   */

  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destination.
   // Pass the selected object to the new view controller.
   }
   */

}

extension JournalEditorViewController: UITextFieldDelegate {

}


