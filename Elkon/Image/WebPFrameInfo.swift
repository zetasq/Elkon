//
//  WebPFrameInfo.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal struct WebPFrameInfo {
  
  internal let canvasSize: CGSize
  
  /// 0-based index
  internal let frameIndex: Int
  
  /// In the Quartz2D coordinator system, where the origin is at the lower-left corner
  internal let frameRect: CGRect
  
  internal let disposeToBackground: Bool
  
  internal let blendWithPreviousFrame: Bool
  
  internal let hasAlpha: Bool

  internal func adjustedFrameRect(for renderConfig: ImageRenderConfig?) -> CGRect {
    let adjustedCanvasSize = canvasSize.adjustedCanvasSize(for: renderConfig)
    let scaleFactor = canvasSize.scaleFactor(for: renderConfig)
    
    
//    var transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
//    transform.concatenating(CGAffineTransform(translationX: (canvasSize.width * scaleFactor - adjustedCanvasSize.width) / 2, y: (canvasSize.height * scaleFactor - adjustedCanvasSize.height) / 2))
//
//    let result = frameRect.applying(transform)
//    return result
//    return frameRect.applying(transform)

    
    let adjustedOrigin = CGPoint(x: (adjustedCanvasSize.width - canvasSize.width * scaleFactor) / 2 + frameRect.origin.x * scaleFactor,
                                 y: (adjustedCanvasSize.height - canvasSize.height * scaleFactor) / 2 + frameRect.origin.y * scaleFactor)
    let adjustedImageSize = CGSize(width: frameRect.width * scaleFactor, height: frameRect.height * scaleFactor)
    
    return CGRect(origin: adjustedOrigin, size: adjustedImageSize)
  }
  
}
