//
//  JournalPhotoScrollViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/15/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PhotoCell"

class JournalPhotoScrollViewController: UIViewController {


  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var pageControl: UIPageControl!

  @IBOutlet var gridButton: UIBarButtonItem!
  @IBOutlet var trashButton: UIBarButtonItem!
  @IBOutlet var cameraButton: UIBarButtonItem!
  @IBOutlet var photosButton: UIBarButtonItem!

  @IBAction func returnToPhotoScroll(_ unwindSegue: UIStoryboardSegue) {
    print("returned from Grid!")
    if let selectedAlbumIndex = selectedAlbumIndex {
      collectionView.scrollToItem(at: selectedAlbumIndex, at: .centeredHorizontally, animated: true)
      pageControl.currentPage = selectedAlbumIndex.row
    }
  }

  @IBAction func displayPhotoGrid(_ sender: Any) {
    print("displaying photo grid!")
    performSegue(withIdentifier: "displayGrid", sender: nil)
  }


  @IBAction func deletePhoto(_ sender: Any) {
    print("about to delete a photo")
  }


  @IBAction func pickPhotoFromCamera(_ sender: Any) {
    print("pick a photo from the camera")
  }


  @IBAction func pickPhotoFromPhotosApp(_ sender: Any) {
    print("pick a photo from the photos app")
  }

  var selectedAlbumIndex: IndexPath?
  var albumEditable = false
  var photos: [UIImage] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configurePageControl()
    configureButtons()
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

  }

   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "displayGrid" {
      print("lets segue to the grid")
      let gridViewController = segue.destination as! JournalPhotoGridViewController
      gridViewController.photos = photos
    }
   }

  private func configureButtons() {
    if albumEditable == false {
      cameraButton.isEnabled = false
      trashButton.isEnabled = false
      photosButton.isEnabled = false
    } else {
      cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
      trashButton.isEnabled = photos.count > 0 ? true : false
      gridButton.isEnabled = photos.count > 0 ? true: false
    }
  }

  private func configurePageControl() {
    pageControl.currentPageIndicatorTintColor = .red
    pageControl.pageIndicatorTintColor = .lightGray
    pageControl.numberOfPages = photos.count

    // this gets the visible cell
    var visibleRect = CGRect()
    visibleRect.origin = collectionView.contentOffset
    visibleRect.size = collectionView.bounds.size

    // then we get a CGPoint for the center of it
    let visiblePoint = CGPoint(x: visibleRect.midX,
                               y: visibleRect.midY)
    // then we get the indexPath for whatever the visiblePoint is...
    guard let indexPath = collectionView.indexPathForItem(at: visiblePoint) else { return }
    pageControl.currentPage = indexPath.row
    print("current page is \(pageControl.currentPage)")
  }

  private func configureCollectionView() {
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.isPagingEnabled = true
  }
}

extension JournalPhotoScrollViewController: UICollectionViewDataSource {

  // MARK: UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of items
    return photos.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! JournalPhotoScrollViewCell
    cell.image = photos[indexPath.row]
    return cell
  }
}
// MARK: UICollectionViewDelegate
extension JournalPhotoScrollViewController: UICollectionViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    configurePageControl()
  }
}

extension JournalPhotoScrollViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width,
                  height: collectionView.frame.height)
  }
}
