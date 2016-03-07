//
//  DismissSegue.swift
//  PhotoMask
//
//  Created by Jia Jing on 3/7/16.
//  Copyright © 2016 Jia Jing. All rights reserved.
//

import Foundation

class DismissSegue: UIStoryboardSegue {
  override func perform() {
    sourceViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
  }
}