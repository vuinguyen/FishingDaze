//
//  JournalPhotoGridViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 2/17/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GridCell"

class JournalPhotoGridViewController: UICollectionViewController {

  @IBOutlet var flowLayout: UICollectionViewFlowLayout!

  var photos: [UIImage] = []
  var selectedIndex: IndexPath?

  override func viewDidLoad() {
    super.viewDidLoad()

    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Register cell classes
    //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    // Do any additional setup after loading the view.
    configureFlowLayout()
  }

  private func configureFlowLayout() {
    let space:CGFloat = 3.0
    let dimension = (view.frame.size.width - (2 * space)) / 3.0

    flowLayout.minimumInteritemSpacing = space
    flowLayout.minimumLineSpacing = space
    flowLayout.itemSize = CGSize(width: dimension, height: dimension)
  }

   // MARK: - Navigation
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ReturnToPhotoScrollSegue" {
      // pass the index back so we can scroll to the selected image
      let photoScrollVC = segue.destination as! JournalPhotoScrollViewController
      photoScrollVC.selectedAlbumIndex = selectedIndex
    }
   }

  // MARK: UICollectionViewDataSource

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }


  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return photos.count
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JournalPhotoGridViewCell
    cell.image = photos[indexPath.row]
    return cell
  }

  // MARK: UICollectionViewDelegate
  // Uncomment this method to specify if the specified item should be selected
  override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    print("item selected at indexPath: \(indexPath)")
    selectedIndex = indexPath
    self.performSegue(withIdentifier: "ReturnToPhotoScrollSegue", sender: nil)
  }
}
