//
//  AnimatedImageDataSource.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/30.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol AnimatedImageDataSource {
  
  var loopCount: LoopCount { get }
  
  var frameCount: Int { get }
  
  var frameDelays: [Double] { get }
  
  init?(data: Data)
  
  func image(at index: Int, previousImage: CGImage?, renderConfig: ImageRenderConfig?) -> CGImage?
  
}
