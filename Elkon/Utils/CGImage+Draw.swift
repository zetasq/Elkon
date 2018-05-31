//
//  CGImage+Draw.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/4/6.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension CGImage {
  
  public func getPredrawnImage() -> CGImage {
    let hasAlpha: Bool
    
    switch self.alphaInfo {
    case .none, .noneSkipFirst, .noneSkipLast:
      hasAlpha = false
    default:
      hasAlpha = true
    }
    
    let size = CGSize(width: self.width, height: self.height)
    UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, 1)
    defer {
      UIGraphicsEndImageContext()
    }
    
    let context = UIGraphicsGetCurrentContext()!
    
    // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    // https://developer.apple.com/library/content/qa/qa1708/_index.html
    context.translateBy(x: 0, y: CGFloat(height))
    context.scaleBy(x: 1, y: -1)
    
    context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height)))
    
    return context.makeImage()!
  }
  
}
