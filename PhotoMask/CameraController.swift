//
//  CameraController.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

final class CameraController: UIViewController {
  let image = Variable(nil as UIImage?)
  var category: PhotoCategory?
  var indexPath: NSIndexPath?
  
  
  let overlayEnabled = Variable(false)
  
  lazy var recorder: SCRecorder = {
    let recorder = SCRecorder()
    recorder.photoConfiguration.enabled = true
    return recorder
  }()
  
  var orientation = UIDeviceOrientation.Portrait

  
  @IBOutlet var rotatable: [UIView]!
  
  
  @IBOutlet weak var overlayButton: UIButton!
  
  @IBOutlet weak var overlayImageView: UIImageView!
  
  let disposeBag = DisposeBag()
  override func viewDidLoad() {
    super.viewDidLoad()
    recorder.previewView = view
    recorder.startRunning()
    image.asObservable().subscribeNext { [weak self] in self?.overlayImageView.image = $0 }.addDisposableTo(disposeBag)
    image.asObservable().map { $0 != nil } .subscribeNext { [weak self] in self?.overlayButton.enabled = $0 }.addDisposableTo(disposeBag)
    overlayEnabled.asObservable().withLatestFrom(image.asObservable().map { $0 != nil }) { $0 && $1 }.subscribeNext { [weak self] in self?.overlayImageView.hidden = !$0 }.addDisposableTo(disposeBag)
    overlayEnabled.asObservable().subscribeNext { [weak self] in self?.overlayButton.selected = $0  }.addDisposableTo(disposeBag)
    overlayButton.rx_tap.subscribeNext { [weak self] in
      guard let enabled = self?.overlayEnabled else { return }
      enabled.value = !enabled.value
    }.addDisposableTo(disposeBag)
    UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onOrientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: UIDevice.currentDevice())
  }
  
  func onOrientationChanged(notification: NSNotification) {
    if let orientation = (notification.object as? UIDevice)?.orientation {
      self.orientation = orientation
      switch orientation {
      case .LandscapeLeft:
        UIView.animateWithDuration(0.3) { self.rotatable.each { $0.layer.setAffineTransform(.makeRotation(CGFloat(M_PI_2))) } }
      case .LandscapeRight:
        UIView.animateWithDuration(0.3) { self.rotatable.each { $0.layer.setAffineTransform(.makeRotation(-CGFloat(M_PI_2))) } }
      default:
        UIView.animateWithDuration(0.3) { self.rotatable.each { $0.layer.setAffineTransform(.identity) } }
      }
    }
  }
  
  override func shouldAutorotate() -> Bool {
    return false
  }
  @IBAction func chooseImage(sender: AnyObject) {
    guard let category = category, indexPath = indexPath else {
      performSegueWithIdentifier("photoCategory", sender: nil)
      return
    }
    
    let nav = UINavigationController()
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let categoryController = storyboard.instantiateViewControllerWithIdentifier("photo-category") as! PhotoCategoryController
    let listController = storyboard.instantiateViewControllerWithIdentifier("photo-list") as! PhotoListController
    categoryController.onImageSelected = { [weak self] category, indexPath, image in
      self?.category = category
      self?.indexPath = indexPath
      self?.image.value = image
      self?.overlayEnabled.value = true
    }
    
    listController.onImageSelected = {[weak self] indexPath, image in
      self?.category = category
      self?.indexPath = indexPath
      self?.image.value = image
      self?.overlayEnabled.value = true
    }
    
    listController.images = category.images.flatMap { UIImage(named: $0) }.compact()
    
    listController.indexPath = indexPath
    nav.pushViewController(categoryController, animated: false)
    nav.pushViewController(listController, animated: false)
    presentViewController(nav, animated: true, completion: nil)
  }
  
  @IBAction func takePhoto(sender: AnyObject) {
    recorder.capturePhoto { _, photo in
      guard let photo = photo?.CGImage else { return }
      
      let image = UIImage(CGImage: photo, scale: 1.0, orientation: self.orientation.asUIImageOrientation)
      self.performSegueWithIdentifier("filter", sender: image)
      
//      URLAlbumCompatible { PHAssetChangeRequest.creationRequestForAssetFromImage(UIImage(CGImage: photo, scale: 1.0, orientation: self.orientation.asUIImageOrientation)) }.saveToAlbum()
    }
  }
  
  @IBAction func switchCamera(sender: AnyObject) {
    switch recorder.device {
    case .Front: recorder.device = .Back
    case .Back: recorder.device = .Front
    case .Unspecified: recorder.device = .Back
    }
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    super.prepareForSegue(segue, sender: sender)
    switch (segue.identifier, segue.destinationViewController, sender) {
    case let ("photoCategory"?, nav as UINavigationController, _):
      guard let controller = nav.topViewController as? PhotoCategoryController else { return }
      controller.onImageSelected = { [weak self] category, indexPath, image in
        self?.category = category
        self?.indexPath = indexPath
        self?.image.value = image
        self?.overlayEnabled.value = true
      }
    case let ("filter"?, controller as FilterController, image as UIImage):
      controller.image = image
    default: ()
    }
  }
}

extension UIDeviceOrientation: CustomStringConvertible {
  var asUIImageOrientation: UIImageOrientation {
    switch self {
    case Unknown: return .Right
    case Portrait: return .Right
    case PortraitUpsideDown: return .Left
    case LandscapeLeft: return .Up
    case LandscapeRight: return .Down
    case FaceUp: return .Right
    case FaceDown: return .Right
    }
  }
  
  public var description: String {
    switch self {
    case Unknown: return "Unknown"
    case Portrait: return "Portrait"
    case PortraitUpsideDown: return "PortraitUpsideDown"
    case LandscapeLeft: return "LandscapeLeft"
    case LandscapeRight: return "LandscapeRight"
    case FaceUp: return "FaceUp"
    case FaceDown: return "FaceDown"
    }

  }
}
