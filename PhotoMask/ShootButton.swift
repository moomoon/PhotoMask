//
//  ShootButton.swift
//  kaipai2
//
//  Created by Jia Jing on 10/8/15.
//  Copyright (c) 2015 Kaipai. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ShootButton: UIControl {
  let selectedVariable = Variable(false)
  
  private var centerColorNormal = UIColor.redColor()
  private var centerColorHighlighted = UIColor.redColor().applyAlpha(0.5)
  private var ringColor = UIColor.whiteColor()
  private var minGapRatio = 0.1471.cgfloat
  private var maxGapRatio = 0.2647.cgfloat
  private var minRadius = 4.cgfloat
  
   var _enabled = true
  private var ringWidth = 2.cgfloat
  override var bounds: CGRect { didSet { updateLayerBounds() } }
   var _highlighted = false { didSet { updateLayerColor() } }
  
  let enablerProperty = Variable { true }
  
  private var centerLayer: CALayer!
  
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initialize()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initialize()
  }
  
  private func initialize() {
    centerLayer = CALayer()
    centerLayer.backgroundColor = centerColorNormal.CGColor
    layer.addSublayer(centerLayer)
    centerLayer.zPosition = CGFloat.min
    
    layer.borderWidth = ringWidth
    layer.borderColor = ringColor.CGColor
    
    
    
    _ = selectedVariable.asObservable().subscribeNext { [weak self] in self?.onStateChange($0) }
    _ = rx_controlEvent(.TouchUpInside).withLatestFrom(enablerProperty.asObservable(), resultSelector: identity).filter { $1($0) }.map { $0.0 }
      .filter { [weak self] in (self?._enabled).isTrue }.subscribeNext { [weak self] in self?.selectedVariable.value = !self!.selectedVariable.value }
    
    
    updateLayerBounds()
    updateLayerColor()
  }
  
  private var edge: CGFloat {
    let bounds = self.bounds
    return min(bounds.width, bounds.height)
  }
  
  private var minGap: CGFloat {
    return edge * minGapRatio
  }
  
  private var maxGap: CGFloat {
    return edge * maxGapRatio
  }
  
  private func updateLayerBounds() {
    let gap = selectedVariable.value ? maxGap : minGap
    centerLayer.frame = bounds.insetBy(dx: gap, dy: gap)
    centerLayer.cornerRadius = selectedVariable.value ? minRadius : centerLayer.bounds.size.maxRadius
    layer.cornerRadius = bounds.size.maxRadius
  }
  
  private func onStateChange(shooting: Bool) {
    _enabled = false
    UIView.animateWithDuration(1.5, animations: {
      let gap = shooting ? self.maxGap : self.minGap
      self.centerLayer.frame = self.bounds.insetBy(dx: gap, dy: gap)
      self.centerLayer.cornerRadius = shooting ? self.minRadius : self.centerLayer.bounds.size.maxRadius
      }) { success in
        self._enabled = true
    }
  }
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard _enabled else { return }
    _highlighted = true
    super.touchesBegan(touches, withEvent: event)
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    _highlighted = false
    super.touchesEnded(touches, withEvent: event)
  }
  
  private func updateLayerColor() {
    centerLayer.backgroundColor = _highlighted ? centerColorHighlighted.CGColor : centerColorNormal.CGColor
  }
}

