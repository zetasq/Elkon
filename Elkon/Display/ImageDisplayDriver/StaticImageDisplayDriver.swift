//
//  StaticImageDisplayDriver.swift
//  Elkon
//
//  Created by Zhu Shengqi on 30/5/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal final class StaticImageDisplayDriver: ImageDisplayDriverProtocol {
  
  internal weak var delegate: ImageDisplayDriverDelegate?
  
  internal let config: ImageDisplayDriverConfig
  
  private let staticImage: StaticImage
  
  internal init(staticImage: StaticImage, config: ImageDisplayDriverConfig) {
    self.staticImage = staticImage
    self.config = config
  }
  
  internal func startDisplay() {
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: staticImage.asUIImage(scale: config.imageScaleFactor), animated: config.shouldAnimate)
  }
  
}
