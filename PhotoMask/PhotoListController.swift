//
//  PhotoListController.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation

final class PhotoListController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var onImageSelected: ((NSIndexPath, UIImage) -> ())!
  var indexPath: NSIndexPath?
  var images: [UIImage]!
  let columnNumber = 2

  
  override func viewDidLoad() {
    super.viewDidLoad()
    if let indexPath = indexPath {
      collectionView?.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: true)
    }
  }
  
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    let cellWidth = (collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - (collectionViewLayout as! UICollectionViewFlowLayout).minimumInteritemSpacing * CGFloat(columnNumber - 1)) / CGFloat(columnNumber)
    return images[indexPath.item].size.fitInWidth(cellWidth)
  }
  
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoListCell
    let image = images[indexPath.item]
    cell.imageView.image = image
    cell.onSelected = { [weak self] in self?.presentingViewController?.dismissViewControllerAnimated(true) { self?.onImageSelected(indexPath, image) } }
    return cell
  }
}


class PhotoListCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  
  var onSelected: Closure!
  @IBAction func onClick(sender: AnyObject) {
    onSelected()
  }
}