//
//  Image.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

public enum ImageResource {
  
  case `static`(StaticImage)
  
  case animated(AnimatedImage)
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "image")

  public init?(data: Data) {
    let imageType = data.imageType
    
    switch imageType {
    case .PNG, .JPG:
      guard let staticImage = StaticImage(data: data) else {
        return nil
      }
      
      self = .static(staticImage)
    default:
      os_log("%@", log: ImageResource.logger, type: .error, "Unsupported image type for decoding: \(imageType)")
      return nil
    }
  }
  
  public var totalByteSize: Int {
    switch self {
    case .static(let staticImage):
      return staticImage.totalByteSize
    case .animated(let animatedImage):
      return animatedImage.totalByteSize
    }
  }
  
}
