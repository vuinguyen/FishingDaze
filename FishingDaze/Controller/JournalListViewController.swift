//
//  ViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 6/20/19.
//  Copyright © 2019 SunfishEmpire. All rights reserved.
//

import UIKit

class JournalListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!

  @IBAction func deleteEntry(_ unwindSegue: UIStoryboardSegue) {
    print("came back from deleting an entry!")
    /*
    guard let editorViewController = unwindSegue.source as? JournalEditorViewController else {
        return
    }
 */
 }
  
  let reuseIdentifier = "JournalEntryCell"
  var selectedIndex = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    tableView.reloadData()
  }

  let fruitArray = ["apples", "grapes", "oranges", "bananas"]

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
      let detailVC = segue.destination as! JournalEntryViewController
      detailVC.fruit = fruitArray[selectedIndex]
    } else if segue.identifier == "addNewEntry" {
      let navigationController = segue.destination as! UINavigationController
      let entryVC = navigationController.viewControllers[0] as! JournalEditorViewController
      entryVC.showDelete = false
    }
  }
}

extension JournalListViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return fruitArray.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)!
    cell.textLabel?.text = fruitArray[indexPath.row]
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndex = indexPath.row
    performSegue(withIdentifier: "showDetail", sender: nil)
    tableView.deselectRow(at: indexPath, animated: true)
    //print("selected this row!")
  }

}



