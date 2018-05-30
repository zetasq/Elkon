//
//  StaticImageDisplayDriver.swift
//  Elkon
//
//  Created by Zhu Shengqi on 30/5/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal final class StaticImageDisplayDriver: ImageDisplayDriverProtocol {
  
  private let staticImage: ImageResource.StaticImage
  
  private let config: ImageDisplayDriverConfig
  
  internal init(staticImage: ImageResource.StaticImage, config: ImageDisplayDriverConfig) {
    self.staticImage = staticImage
    self.config = config
  }
  
  internal weak var delegate: ImageDisplayDriverDelegate?
  
  func startDisplay() {
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: staticImage.asUIImage(scale: config.imageScaleFactor), animated: config.shouldAnimate)
  }
  
}
