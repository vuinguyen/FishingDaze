//
//  JournalPhotoScrollViewController.swift
//  FishingDaze
//
//  Created by Vui Nguyen on 1/15/20.
//  Copyright © 2020 SunfishEmpire. All rights reserved.
//

import UIKit

private let reuseIdentifier = "PhotoCell"

class JournalPhotoScrollViewController: UIViewController, UINavigationControllerDelegate {


  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var pageControl: UIPageControl!

  @IBOutlet var gridButton: UIBarButtonItem!
  @IBOutlet var trashButton: UIBarButtonItem!
  @IBOutlet var cameraButton: UIBarButtonItem!
  @IBOutlet var libraryButton: UIBarButtonItem!

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
    let destroyAction = UIAlertAction(title: "Delete",
                                      style: .destructive) { (action) in
                                      self.deleteImage()
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let alert = UIAlertController(title: "Delete Picture?", message: "",
                                  preferredStyle: .actionSheet)
    alert.addAction(destroyAction)
    alert.addAction(cancelAction)

    // On iPad, action sheets must be presented from a popover.
    alert.popoverPresentationController?.barButtonItem = trashButton

    self.present(alert, animated: true, completion: nil)
  }


  @IBAction func pickPhotoFromCamera(_ sender: Any) {
    print("pick a photo from the camera")
    pickImage(isSourceLibrary: false)
  }


  @IBAction func pickPhotoFromPhotoLibrary(_ sender: Any) {
    print("pick a photo from the photos app")
    pickImage(isSourceLibrary: true)
  }

  var selectedAlbumIndex: IndexPath?
  var albumEditable = false
  var photos: [UIImage] = []
  var photoScrollDelegate: PhotoScrollDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configurePageControl()
    configureButtons()
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
  }

  /*
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    configureCollectionView()
    configurePageControl()
    configureButtons()
  }
 */

   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "displayGrid" {
      print("lets segue to the grid")
      let gridViewController = segue.destination as! JournalPhotoGridViewController
      gridViewController.photos = photos
    }
   }

  // MARK: Private Helper Functions

  private func configureButtons() {
    gridButton.isEnabled = photos.count > 0 ? true: false

    if albumEditable == false {
      cameraButton.isEnabled = false
      trashButton.isEnabled = false
      libraryButton.isEnabled = false
    } else {
      cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
      trashButton.isEnabled = photos.count > 0 ? true : false
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
    //collectionView.reloadData()
  }

  private func pickImage(isSourceLibrary: Bool) {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
    imagePickerController.sourceType = isSourceLibrary ? .photoLibrary : .camera
    present(imagePickerController, animated: true, completion: nil)
  }

  private func addImage(image: UIImage) {
    var currentPageIndex = IndexPath(row: 0, section: 0)

    if ((pageControl?.currentPage) != nil) {
      currentPageIndex = IndexPath(row: pageControl.currentPage, section: 0)
    }

    print("at page \(currentPageIndex)")
    // insert picture at that spot
    photos.insert(image, at: currentPageIndex.row)
    // refresh collection view
    collectionView.reloadData()

    // scroll to newly added item
    pageControl.numberOfPages = photos.count
    collectionView.scrollToItem(at: currentPageIndex, at: .centeredHorizontally, animated: true)
    pageControl.currentPage = currentPageIndex.row

    if let delegate = photoScrollDelegate {
      delegate.addPhoto(photoToAdd: image, updatedPhotos: photos)
    }
  }

  private func deleteImage() {
    if ((pageControl?.currentPage) == nil) {
      print("no image to delete")
      return
    }

    let currentPageIndex = IndexPath(row: pageControl.currentPage, section: 0)

    // remove picture at that spot
    let photoToRemove = photos.remove(at: currentPageIndex.row)

    // refresh colleciton view
    collectionView.reloadData()

    // update the number of dots
    pageControl.numberOfPages = photos.count

    // this gets the visible cell
    var visibleRect = CGRect()
    visibleRect.origin = collectionView.contentOffset
    visibleRect.size = collectionView.bounds.size

    // scroll to the picture before the deleted picture
    collectionView.scrollRectToVisible(visibleRect, animated: true)

    if let delegate = photoScrollDelegate {
      delegate.deletePhoto(photoToDelete: photoToRemove, updatedPhotos: photos)
    }
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

  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // after deleting a cell
    configureButtons()
  }

  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    // about to add a cell
    configureButtons()
  }
}

extension JournalPhotoScrollViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.bounds.width,
                  height: collectionView.frame.height)
  }
}

// MARK: ImagePickerControllerDelegate
extension JournalPhotoScrollViewController: UIImagePickerControllerDelegate {
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
  }

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

    print("we got into imagepickercontroller code")
    //picker.dismiss(animated: false, completion: nil)
    if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      addImage(image: image)
    } else {
      let alert = UIAlertController(title: "Picture Selection Error", message: "Failed To Select Picture",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"),
                                    style: .default, handler: { _ in
        print("There was an error in selecting a picture")
      }))
      self.present(alert, animated: true, completion: nil)
    }

    picker.dismiss(animated: true, completion: nil)
  }
}
