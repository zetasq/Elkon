//
//  CGImage+Draw.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/4/6.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension CGImage {
  
  public func predrawnImage(with renderConfig: ImageRenderConfig?) -> CGImage {
    let imageSize = CGSize(width: self.width, height: self.height)
    let bitmapSize = imageSize.adjustedCanvasSize(for: renderConfig)
    
    let renderer = UIGraphicsImageRenderer(size: bitmapSize)
    let drawnImage = renderer.image { rendererContext in
      let bitmapContext = rendererContext.cgContext
      
      // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
      // https://developer.apple.com/library/content/qa/qa1708/_index.html
      bitmapContext.translateBy(x: 0, y: bitmapSize.height)
      bitmapContext.scaleBy(x: 1, y: -1)
      
      if let renderConfig = renderConfig, renderConfig.needsToClipWithCornerRadius {
        let roundedSize = renderConfig.sizeInPixels
        let roundedRect = CGRect(origin: CGPoint(x: (bitmapSize.width - roundedSize.width) / 2,
                                                 y: (bitmapSize.height - roundedSize.height) / 2),
                                 size: roundedSize)
        
        let bezierPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: renderConfig.cornerRadiusInPixels)
        bitmapContext.addPath(bezierPath.cgPath)
        bitmapContext.clip()
      }
      
      let scaleFactor = imageSize.scaleFactor(for: renderConfig)
      let sizeToDraw = CGSize(width: imageSize.width * scaleFactor, height: imageSize.height * scaleFactor)
      
      bitmapContext.draw(
        self,
        in: CGRect(origin: CGPoint(x: (bitmapSize.width - sizeToDraw.width) / 2,
                                   y: (bitmapSize.height - sizeToDraw.height) / 2),
                   size: sizeToDraw))
    }
    
    return drawnImage.cgImage!
  }
  
}
