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

  public init?(data: Data, renderConfig: ImageRenderConfig?) {
    let imageType = data.imageType
    
    switch imageType {
    case .PNG, .JPG:
      guard let staticImage = StaticImage(data: data, renderConfig: renderConfig) else {
        return nil
      }
      
      self = .static(staticImage)
    case .GIF:
      guard let gifImageDataSource = GIFImageDataSource(data: data),
        let animatedImage = AnimatedImage(dataSource: gifImageDataSource, renderConfig: renderConfig) else {
        return nil
      }
      
      self = .animated(animatedImage)
    case .WebP:
      guard let webpImageDataSource = WebPImageDataSource(data: data),
        let animatedImage = AnimatedImage(dataSource: webpImageDataSource, renderConfig: renderConfig) else {
        return nil
      }
      
      self = .animated(animatedImage)
    default:
      os_log("%@", log: ImageResource.logger, type: .error, "Unsupported image type for decoding: \(imageType)")
      return nil
    }
  }
  
  public init(uiImage: UIImage) {
    self = .static(StaticImage(uiImage: uiImage))
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
