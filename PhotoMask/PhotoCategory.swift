//
//  PhotoCategory.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation

struct PhotoCategory {
  let title: String
  let cover: String
  let images: [String]
  
  static var allItems: [PhotoCategory] {
    var items = [PhotoCategory]()
    items.append(PhotoCategory(title: "沙滩", cover: "beach_0048.jpg", images: (1...58).map { "beach_\($0.format("04")).jpg" }))
    items.append(PhotoCategory(title: "儿童", cover: "child_0006.jpg", images: (1...72).map { "child_\($0.format("04")).jpg" }))
    items.append(PhotoCategory(title: "人像", cover: "portrait_0002.jpg", images: (1...68).map { "portrait_\($0.format("04")).jpg" }))
    return items
  }
}