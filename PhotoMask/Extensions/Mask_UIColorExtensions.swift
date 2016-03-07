//
//  Mask_UIColorExtensions.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation

extension UIColor {
  func applyAlpha(alpha: CGFloat) -> UIColor {
    let (red, green, blue, _) = components
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red = 0.cgfloat, green = 0.cgfloat, blue = 0.cgfloat, alpha = 0.cgfloat
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red, green, blue, alpha)
  }

}