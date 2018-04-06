//
//  CGImage+Draw.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/4/6.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension CGImage {
  
  public func generateBitmapImage() -> CGImage {
    let hasAlpha: Bool
    
    switch self.alphaInfo {
    case .none, .noneSkipFirst, .noneSkipLast:
      hasAlpha = false
    default:
      hasAlpha = true
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: self.width, height: self.height), !hasAlpha, 1)
    defer {
      UIGraphicsEndImageContext()
    }
    
    let context = UIGraphicsGetCurrentContext()!
    context.draw(self, in: CGRect(origin: .zero, size: CGSize(width: self.width, height: self.height)))
    
    return context.makeImage()!
  }
  
}
