//
//  ImageResource+StaticImage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/29.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

public enum StaticImage {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageResource.StaticImage")
  
  case cgImage(CGImage, CGImagePropertyOrientation)
  
  case uiImage(UIImage)
  
  public init?(data: Data) {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary) else {
      os_log("%@", log: StaticImage.logger, type: .error, "Failed to create CGImageSource with data")
      return nil
    }
    
    guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
      os_log("%@", log: StaticImage.logger, type: .error, "Failed to create create image at index 0 from CGImageSource")
      return nil
    }
    
    let orientation: CGImagePropertyOrientation
    if let properties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any],
      let orientationValue = properties[kCGImagePropertyOrientation as String] as? UInt32 {
      orientation = CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
    } else {
      orientation = .up
    }
    
    self = .cgImage(cgImage.getPredrawnImage(), orientation)
  }
  
  public var totalByteSize: Int {
    switch self {
    case .cgImage(let cgImage, _):
      return cgImage.bytesPerRow * cgImage.height
    case .uiImage(let uiImage):
      guard let cgImage = uiImage.cgImage else {
        return 0
      }
      return cgImage.bytesPerRow * cgImage.height
    }
  }
  
  public func asUIImage(scale: CGFloat) -> UIImage {
    switch self {
    case .cgImage(let cgImage, let cgImagePropertyOrientation):
      return UIImage(cgImage: cgImage, scale: scale, orientation: UIImageOrientation(cgImagePropertyOrientation))
    case .uiImage(let uiImage):
      if uiImage.scale == scale {
        return uiImage
      }
      
      guard let cgImage = uiImage.cgImage else {
        return uiImage
      }
      
      return UIImage(cgImage: cgImage, scale: scale, orientation: uiImage.imageOrientation)
    }
  }
  
}

