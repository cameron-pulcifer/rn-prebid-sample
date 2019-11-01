//
//  CounterViewManager.swift
//  SecondCocoa
//
//  Created by Cameron Pulcifer on 10/10/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

//import Foundation

@objc(CounterViewManager)
class CounterViewManager: RCTViewManager {
  
  override func view() -> UIView! {
//    let label = UILabel()
//    label.text = "Swift Counter"
//    label.textAlignment = .center
//    return label
    return CounterView()
  }
  
  @objc func updateFromManager(_ node: NSNumber, count: NSNumber) {
    DispatchQueue.main.async {
      // self.bridge is from super
      let component = self.bridge.uiManager.view(forReactTag: node) as! CounterView
      component.update(value: count)
    }
  }
  
  // gets rid of warning in simulator
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
}
