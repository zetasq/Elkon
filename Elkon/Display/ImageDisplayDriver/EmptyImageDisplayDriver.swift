//
//  EmptyImageDisplayDriver.swift
//  Elkon
//
//  Created by Zhu Shengqi on 30/5/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal final class EmptyImageDisplayDriver: ImageDisplayDriverProtocol {
  
  internal weak var delegate: ImageDisplayDriverDelegate?
  
  internal let config: ImageDisplayDriverConfig
  
  internal init(config: ImageDisplayDriverConfig) {
    self.config = config
  }
  
  internal func startDisplay() {
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: nil, animated: config.shouldAnimate)
  }
  
}
