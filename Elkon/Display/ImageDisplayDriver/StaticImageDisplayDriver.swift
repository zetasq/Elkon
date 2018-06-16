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
  
  internal let driverConfig: ImageDisplayDriverConfig
  
  private let staticImage: StaticImage
  
  internal init(staticImage: StaticImage, driverConfig: ImageDisplayDriverConfig) {
    self.staticImage = staticImage
    self.driverConfig = driverConfig
  }
  
  internal func startDisplay() {
    delegate?.imageDisplayDriverRequestDisplayingImage(self, image: staticImage.asUIImage(), animated: driverConfig.shouldAnimate)
  }
  
}
