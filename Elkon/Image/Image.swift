//
//  Image.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

public enum Image {
  
  case `static`(StaticImage)
  
  case animated(AnimatedImage)
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "image")

  public init?(data: Data) {
    let imageType = data.imageType
    
    switch imageType {
    case .PNG, .JPG:
      guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
        os_log("%@", log: Image.logger, type: .error, "Failed to create CGImageSource with data")
        return nil
      }
      
      guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        os_log("%@", log: Image.logger, type: .error, "Failed to create create image at index 0 from CGImageSource")
        return nil
      }
      
      let orientation: CGImagePropertyOrientation
      if let properties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any],
        let orientationValue = properties[kCGImagePropertyOrientation as String] as? UInt32 {
        orientation = CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
      } else {
        orientation = .up
      }
      
      let staticImage = StaticImage(cgImage: cgImage.generateBitmapImage(), orientation: orientation)
      self = .static(staticImage)
    default:
      os_log("%@", log: Image.logger, type: .error, "Unsupported image type for decoding: \(imageType)")
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
