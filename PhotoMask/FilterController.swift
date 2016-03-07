//
//  FilterController.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation
import RxSwift
import CoreImage
import Photos

final class FilterController: UIViewController, UICollectionViewDataSource {
  
  var image: UIImage!
  let filters = allFilters
  let selectedFilter = Variable(nil as FilterType?)
  let disposeBag = DisposeBag()
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    selectedFilter.asObservable().subscribeNext { [weak self] filter in
      guard let image = self?.image else { return }
      self?.backgroundImageView.image = CIImage(image: image).flatMap { filter?.filter($0) }.flatMap(UIImage.init) ?? image
    }.addDisposableTo(disposeBag)
  }
  
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return filters.count
  }
  

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! FilterCell
    let filter = filters[indexPath.item]
    cell.imageView.image = UIImage(named: filter.poster)
    cell.label.text = filter.title
    cell.onSelected = { [weak self] in
      if self?.selectedFilter.value?.title == filter.title {
        self?.selectedFilter.value = nil
      } else {
        self?.selectedFilter.value = filter
      }
    }
    return cell
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  
  @IBAction func onCancel(sender: AnyObject) {
    presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func onSave(sender: AnyObject) {
    guard let image = self.backgroundImageView.image else { return }
    URLAlbumCompatible { PHAssetChangeRequest.creationRequestForAssetFromImage(image) }.saveToAlbum { success, arg, error in
      print("error \(error)")
      if success {
        let controller = UIAlertController(title: "保存成功", message: nil, preferredStyle: .Alert)
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC)), dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true) { self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil) }
          }
        self.presentViewController(controller, animated: true, completion: nil)
      } else {
        let controller = UIAlertController(title: "保存失败", message: nil, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "确定", style: .Default, handler: nil))
        self.presentViewController(controller, animated: true, completion: nil)

      }
    }
  }
  
}


class FilterCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var label: UILabel!
  var onSelected: Closure!
  @IBAction func onClick(sender: AnyObject) {
    onSelected()
  }
}
