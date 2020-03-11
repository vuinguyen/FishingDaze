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
    print("return to Journal List!")
    //journalEntryViewModels = JournalEntryViewModel.fetchJournalEntryViewModels(UIcompletion: self.tableView.reloadData)
    /*
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
 */
    //tableView.reloadData()
    journalEntryViewModels = JournalEntryViewModel.fetchJournalEntryViewModels()
    tableView.reloadData()
  }

  let reuseIdentifier = "JournalEntryCell"
  var selectedIndex = 0
  var journalEntryViewModels = [JournalEntryViewModel]()

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    //journalEntryViewModels = JournalEntryViewModel.fetchJournalEntryViewModels(UIcompletion: self.tableView.reloadData)
    /*
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
 */
    journalEntryViewModels = JournalEntryViewModel.fetchJournalEntryViewModels()
    tableView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      let detailVC = segue.destination as! JournalEntryViewController

      // before we segue, this is where we need to grab the rest of the core data
      // for the Entry
      let journalEntryViewModelWithData = journalEntryViewModels[selectedIndex]
      journalEntryViewModelWithData.fetch()
      detailVC.journalEntryViewModel = journalEntryViewModelWithData
    } else if segue.identifier == "addNewEntry" {
      let navigationController = segue.destination as! UINavigationController
      let entryVC = navigationController.viewControllers[0] as! JournalEditorViewController
      entryVC.showDelete = false
    }
  }


}

extension JournalListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return journalEntryViewModels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)! as! JournalListTableViewCell
    cell.fishingDateLabel.text = journalEntryViewModels[indexPath.row].startDateDisplay()
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndex = indexPath.row
    performSegue(withIdentifier: "showDetail", sender: nil)
    tableView.deselectRow(at: indexPath, animated: true)
  }

}



