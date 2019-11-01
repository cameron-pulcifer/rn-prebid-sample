//
//  CounterView.swift
//  SecondCocoa
//
//  Created by Cameron Pulcifer on 10/10/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UIKit

class CounterView: UIView {
  
  // exposed to RN as prop
  @objc var count: NSNumber = 0 {
    didSet {
      button.setTitle(String(describing: count), for: .normal)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.addSubview(button)
    increment()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // exposed to RN as function
  @objc var onUpdate: RCTDirectEventBlock?
  
  
  lazy var button: UIButton = {
    let b = UIButton.init(type: UIButton.ButtonType.system)
    b.titleLabel?.font = UIFont.systemFont(ofSize: 50)
    b.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    b.addTarget(
      self,
      action: #selector(increment),
      for: .touchUpInside
    )
    
    let longPress = UILongPressGestureRecognizer(
      target: self,
      action: #selector(sendUpdate(_:))
    )
    b.addGestureRecognizer(longPress)
    
    
    return b
  }()
  
  @objc func sendUpdate(_ gesture: UILongPressGestureRecognizer) {
    if gesture.state == .began {
      if onUpdate != nil {
        onUpdate!(["count": count])
      }
    }
  }
  
  // exposed to RN
  @objc func update(value: NSNumber) {
    count = value
  }
  
  
  
  
  
  
  @objc func increment() {
    count = count.intValue + 1 as NSNumber
  }
  
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
