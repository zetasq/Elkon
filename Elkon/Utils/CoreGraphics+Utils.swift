//
//  CoreGraphics+Utils.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/16.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension CGSize {
  
  internal func scaleFactor(for renderConfig: ImageRenderConfig?) -> CGFloat {
    guard let config = renderConfig else {
      return 1
    }
    
    let targetSize = config.sizeInPixels
    
    switch config.scaleMode {
    case .fit:
      return min(targetSize.width / CGFloat(self.width), targetSize.height / CGFloat(self.height))
    case .fill:
      return max(targetSize.width / CGFloat(self.width), targetSize.height / CGFloat(self.height))
    }
  }
  
  internal func adjustedCanvasSize(for renderConfig: ImageRenderConfig?) -> CGSize {
    if let renderConfig = renderConfig {
      return renderConfig.sizeInPixels
    } else {
      return self
    }
  }
  
}
