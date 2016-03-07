//
//  PhotoCategoryController.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation
import Box

final class PhotoCategoryController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
  var onImageSelected: ((PhotoCategory, NSIndexPath, UIImage) -> ())!
  let items = PhotoCategory.allItems
  
  @IBAction func onBackPressed(sender: AnyObject) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }
  
//  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//    return collectionView.frame.size.scale(0.25)
//  }
  
  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! PhotoCategoryCell
    let category = items[indexPath.item]
    cell.imageView.image = UIImage(named: category.cover)
    cell.titleLabel.text = category.title
    cell.onSelected = { [weak self] in self?.performSegueWithIdentifier("photoList", sender: Box(category)) }

    return cell
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    switch (segue.identifier, segue.destinationViewController, sender) {
    case let ("photoList"?, controller as PhotoListController, box as Box<PhotoCategory>):
      controller.onImageSelected = { [weak self] indexPath, image in self?.onImageSelected(box.value, indexPath, image) }
      controller.images = box.value.images.flatMap { UIImage(named: $0) }.compact()
    default: ()
    }
  }
}


class PhotoCategoryCell: UICollectionViewCell {
  var onSelected: Closure!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBAction func onClick(sender: AnyObject) {
    onSelected()
  }
}