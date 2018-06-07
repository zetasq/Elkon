//
//  AnimatedImage+FrameResult.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/7.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension AnimatedImage {

  public struct FrameResult {
    
    public let frameIndex: Int
    
    public let frameImage: CGImage
    
    internal init(frameIndex: Int, frameImage: CGImage) {
      self.frameIndex = frameIndex
      self.frameImage = frameImage
    }
    
  }
  
}
