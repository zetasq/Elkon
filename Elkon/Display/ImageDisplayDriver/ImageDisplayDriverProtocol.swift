//
//  ImageDisplayDriverProtocol.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/30.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal protocol ImageDisplayDriverDelegate: AnyObject {
  
  func imageDisplayDriverRequestDisplayingImage(_ driver: ImageDisplayDriverProtocol, image: UIImage?, animated: Bool)
  
}

internal protocol ImageDisplayDriverProtocol: AnyObject {
  
  var delegate: ImageDisplayDriverDelegate? { get set }
  
  func startDisplay()
  
}

internal func ImageDisplayDriverMakeWithResource(_ imageResource: ImageResource, driverConfig: ImageDisplayDriverConfig) -> ImageDisplayDriverProtocol {
  switch imageResource {
  case .static(let staticImage):
    return StaticImageDisplayDriver(staticImage: staticImage, driverConfig: driverConfig)
  case .animated(let animatedImage):
    return AnimatedImageDisplayDriver(animatedImage: animatedImage, driverConfig: driverConfig)
  }
}
