//
//  PhotoKitExtensions.swift
//  kaipai2
//
//  Created by Phoebe Hu on 9/19/15.
//  Copyright (c) 2015 Kaipai. All rights reserved.
//

import Foundation
import Photos


func PHAssetSaveToAlbum(creationRequest: () -> PHAssetChangeRequest?, inCollection collection: PHAssetCollection? = nil, onComplete completionHandler: ((Bool, String!, NSError!) -> ())? = nil) {
  var localIdentifier: String?
  let changes: dispatch_block_t = {
    guard let creation = creationRequest(), placeholder = creation.placeholderForCreatedAsset else { return }
    
    localIdentifier = placeholder.localIdentifier
    collection.flatMap(PHAssetCollectionChangeRequest.init)?.addAssets([placeholder])
  }
  
  //  let startTime = NSDate.timeIntervalSinceReferenceDate()
  //  if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.Authorized {
  //    print("已授权")
  //  }
  
  
  PHPhotoLibrary.sharedPhotoLibrary().performChanges(changes) { success, error in
    if let outerCompletionHandler = completionHandler {
      dispatch_async(dispatch_get_main_queue()){
        outerCompletionHandler(success, localIdentifier, error)
      }
    }
  }
}



protocol AlbumCompatible {
  func saveToAlbum(inCollection collection: PHAssetCollection?, onComplete completionHandler: ((Bool, String!, NSError!) -> ())?)
}

enum URLMediaType {
  case Image, Video
}

extension PHAsset {
//  func thumbnailDisplayable(placeHolderImage: UIImage? = nil) -> Displayable {
//    let delegate: UIImageView -> () = { imageView in
//      let imageView = imageView
//      PHImageManager.defaultManager().requestImageForAsset(self, targetSize: imageView.bounds.size, contentMode: PHImageContentMode.AspectFill, options: nil){ img, opt in
//        imageView.image = img
//      }
//    }
//    return DelegateDisplayable(disposePrev: nil, delegate: delegate, placeHolderImage: placeHolderImage)
//  }
  
  func requestAVAsset(options: PHVideoRequestOptions? = nil, resultHandler: ((AVAsset?, AVAudioMix?, [NSObject : AnyObject]?) -> Void)) -> PHImageRequestID {
    return PHImageManager.defaultManager().requestAVAssetForVideo(self, options: options, resultHandler: resultHandler)
  }
  
  var pixelSize: CGSize {
    return CGSize(width: pixelWidth.cgfloat, height: pixelHeight.cgfloat)
  }
}


//extension AVAsset {
//  func thumbnailDisplayable(size: CGSize? = nil, placeHolderImage: UIImage? = nil, timePoint: CMTime = kCMTimeZero) -> Displayable {
//    let disposePrev: Closure? = nil
//    let delegate: UIImageView -> () = { imageView in
//      let times = [NSValue(CMTime: timePoint)]
//      AVAssetImageGenerator(asset: self).generateCGImagesAsynchronouslyForTimes(times) {_, cgImage, _, _, _ in
//        if let cgImage = cgImage {
//          MainQueue.dispatchAsync {
//            imageView.image = UIImage(CGImage: cgImage)
//          }
//        }
//      }
//    }
//    return DelegateDisplayable(disposePrev: disposePrev, delegate: delegate, placeHolderImage: placeHolderImage)
//  }
//}



struct URLAlbumCompatible: AlbumCompatible {
  let creationRequest: () -> PHAssetChangeRequest?
  func saveToAlbum(inCollection collection: PHAssetCollection? = nil, onComplete completionHandler: ((Bool, String!, NSError!) -> ())? = nil) {
    PHAssetSaveToAlbum(creationRequest, inCollection: collection, onComplete: completionHandler)
    
  }
}


extension NSURL {
  func asMedia(type: URLMediaType) -> URLAlbumCompatible {
    switch type {
    case .Image: return URLAlbumCompatible{ PHAssetChangeRequest.creationRequestForAssetFromImageAtFileURL(self) }
    case .Video: return URLAlbumCompatible{ PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(self) }
    }
  }
}

extension PHFetchResult {
  var PHAssets: [PHAsset] {
    return (0 ..< count).map{ self[$0] as? PHAsset }.compact()
  }
}


func PHAssetsTyped(mediaType: PHAssetMediaType) -> [PHAsset] {
  return PHAsset.fetchAssetsWithMediaType(mediaType, options: nil).PHAssets
}
//var PHVideoAssets: [PHAsset] {
//  return PHAsset.fetchAssetsWithMediaType(.Video, options: nil).PHAssets
//}

struct PlainDate: Hashable {
  let year: Int
  let month: Int
  let day: Int
  let rawDate: NSDate
  
  var hashValue: Int {
    return year * 10000 + month * 100 + day
  }
  
  var friendlyText: String {
    let today = NSDate().julianDate.int
    let diff = rawDate.julianDate.int - today
    switch diff {
    case -2: return "前天"
    case -1: return "昨天"
    case 0: return "今天"
    case 1: return "明天"
    case 2: return "后天"
    default: return plainText
    }
  }
  
  var plainText: String {
    if NSDate().components(.Year).year == year {
      return String(format: "%d月%d日", month, day)
    } else {
      return String(format: "%02d年%d月%d日", year % 100 , month, day)
    }
  }
  
  
  static func from(date: NSDate) -> PlainDate {
    let components = date.components([.Year, .Month, .Day])
    return PlainDate(year: components.year, month: components.month, day: components.day, rawDate: date)
  }
  
}

extension PlainDate {
  func isAfterOrEqual(other: PlainDate) -> Bool {
    return year > other.year
      || (year == other.year && month > other.month)
      || (year == other.year && month == other.month && day >= other.day)
  }
}



func ==(lhs: PlainDate, rhs: PlainDate) -> Bool {
  return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
}


struct DateTime {
  let plainDate: PlainDate
  let hour: Int
  let minute: Int
  let date: NSDate
  
  var timeText: String {
    return String(format: "%d:%02d", hour, minute)
  }
  
  var ampm: String {
    switch hour {
    case 0 ..< 12: return "上午"
    default: return "下午"
    }
  }
  
  var dateTimeText: String {
    return "\(plainDate.friendlyText) \(ampm)"
  }
  
  
  var friendlyText: String {
    
    let seconds = -date.timeIntervalSinceNow
    if seconds < 60 { return "刚刚" }
    
    let minutes = Int(seconds / 60)
    if minutes < 30 { return "\(minutes)分钟前" }
    if minutes < 60 { return "半小时前" }
    
    let hours = Int(seconds / 3600)
    if hours < 12 { return "\(hours)小时前" }
    if hours < 24 { return "半天前" }
    
    let days = Int(seconds / 3600 / 24)
    if days < 7 { return "\(days)天前" }
    
    let weeks = Int(seconds / 3600 / 24 / 7)
    if weeks < 2 { return "\(weeks)周前" }
    
    let current = NSDate().dateTime
    let years = current.plainDate.year - plainDate.year
    let months = current.plainDate.month - plainDate.month + years * 12
    if months <= 1 { return "上个月" }
    if months < 12 { return "\(months)个月前" }
    if years <= 1 { return "去年" }
    return "\(years)年前"
    
    
    //    return plainDate.friendlyText
    
  }
  
  static func from(date: NSDate) -> DateTime {
    let components = date.components([.Hour, .Minute])
    return DateTime(plainDate: PlainDate.from(date), hour: components.hour, minute: components.minute, date: date)
  }
}

extension NSDate {
  
  func components(unitFlags: NSCalendarUnit) -> NSDateComponents {
    return NSCalendar.currentCalendar().components(unitFlags, fromDate: self)
  }
  
  var plainDate: PlainDate {
    return PlainDate.from(self)
  }
  
  var dateTime: DateTime {
    return DateTime.from(self)
  }
  
  func isAfterOrEqual(other: NSDate) -> Bool {
    return compare(other) != NSComparisonResult.OrderedAscending
  }
  
  var julianDate: Double {
    let julianDate19700101 = 2440587.5
    return julianDate19700101 + timeIntervalSince1970 / 86400
  }
  
  static func fromJulianDate(julianDate: Double) -> NSDate {
    let julianDate19700101 = 2440587.5
    return NSDate(timeIntervalSince1970: (julianDate - julianDate19700101) * 86400)
  }
}

