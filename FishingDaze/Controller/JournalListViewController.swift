//
//  ViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/20/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit
//import CoreData

class JournalListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  @IBAction func returnToJournalList(_ unwindSegue: UIStoryboardSegue) {
    print("came back from deleting an entry!")
    /*
    guard let editorViewController = unwindSegue.source as? JournalEditorViewController else {
        return
    }
 */
    tableView.reloadData()
 }

  //var appDelegate: AppDelegate!
  //var managedContext: NSManagedObjectContext!
  let reuseIdentifier = "JournalEntryCell"
  var selectedIndex = 0
  //var journalEntries = [JournalEntryModel]()
  var journalEntryViewModels = [JournalEntryViewModel]()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    //setUpCoreData()
    //tableView.reloadData()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //setUpCoreData()

    //fetchJournalEntries()

    journalEntryViewModels = JournalEntryViewModel.fetchJournalEntryViewModels()

    tableView.reloadData()
  }

  /*
  func setUpCoreData() {
    appDelegate = UIApplication.shared.delegate as? AppDelegate
    managedContext = appDelegate.persistentContainer.viewContext
  }
 */

  /*
  func fetchJournalEntries() {



    //journalEntries = []
    journalEntryViewModels = []
    do {
      let fetchRequest:NSFetchRequest<Entry> = Entry.fetchRequest()
      let entries = try managedContext.fetch(fetchRequest)
      for entry in entries {
        if let endDate = entry.value(forKeyPath: "endDate") as? Date,
           let startDate = entry.value(forKeyPath: "startDate") as? Date,
           let creationDate = entry.value(forKeyPath: "creationDate") as? Date {
           //let journalEntry = JournalEntryModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
           //journalEntries.append(journalEntry)

           let journalEntryViewModel = JournalEntryViewModel(creationDate: creationDate, endDate: endDate, startDate: startDate)
           journalEntryViewModels.append(journalEntryViewModel)

           print("loaded creationDate: \(creationDate)")
           print("loaded endDate: \(endDate)")
           print("loaded startDate: \(startDate)\n")
        }
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }

  }
 */

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      let detailVC = segue.destination as! JournalEntryViewController
//      detailVC.journalEntry = journalEntries[selectedIndex]

      detailVC.journalEntryViewModel = journalEntryViewModels[selectedIndex]

    } else if segue.identifier == "addNewEntry" {
      let navigationController = segue.destination as! UINavigationController
      let entryVC = navigationController.viewControllers[0] as! JournalEditorViewController
      entryVC.showDelete = false
    }
  }
}

extension JournalListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //return journalEntries.count
    return journalEntryViewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as! JournalEntryTableViewCell
    //cell.fishingDateLabel.text = journalEntries[indexPath.row].startDate.string(dateStyle: .long)

    cell.fishingDateLabel.text = journalEntryViewModels[indexPath.row].startDate()
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndex = indexPath.row
    performSegue(withIdentifier: "showDetail", sender: nil)
    tableView.deselectRow(at: indexPath, animated: true)
  }

}



