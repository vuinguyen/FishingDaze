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

  lazy var photos: [UIImage] = { [weak self] in
  var images: [UIImage] = []
  ["testPhoto1", "testPhoto2", "testPhoto3"].forEach { imageName in
    if let image = UIImage(named: imageName) {
      images.append(image)
    }
  }

  return images
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    configurePageControl()
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Register cell classes
    //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    // Do any additional setup after loading the view.
  }

  /*
   // MARK: - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using [segue destinationViewController].
   // Pass the selected object to the new view controller.
   }
   */


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
