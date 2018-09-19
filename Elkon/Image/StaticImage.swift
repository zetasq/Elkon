//
//  ImageResource+StaticImage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/29.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

public struct StaticImage {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageResource.StaticImage")
  
  private enum _Storage {
    case bitmap(CGImage, CGImagePropertyOrientation)
    case opaque(UIImage)
  }
  
  private let _storage: _Storage
  
  public init?(data: Data, renderConfig: ImageRenderConfig?) {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
      os_log("%@", log: StaticImage.logger, type: .error, "Failed to create CGImageSource with data")
      return nil
    }
    
    let cgImage: CGImage
    let orientation: CGImagePropertyOrientation
    
    if let config = renderConfig {
      let imageOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: false,
        kCGImageSourceThumbnailMaxPixelSize: config.maxDimensionInPixels
        ] as CFDictionary
      
      guard let thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, imageOptions) else {
        return nil
      }
      
      cgImage = thumbnailImage
      
      orientation = .up // Because we set kCGImageSourceCreateThumbnailWithTransform to true
    } else {
      let imageOptions = [
        kCGImageSourceShouldCacheImmediately: false,
        ] as CFDictionary
      
      guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, imageOptions) else {
        return nil
      }
      
      cgImage = image
      
      if let properties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any],
        let orientationValue = properties[kCGImagePropertyOrientation as String] as? UInt32 {
        orientation = CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
      } else {
        orientation = .up
      }
    }
    
    let decodedImage = cgImage.predrawnImage(with: renderConfig)
    self._storage = .bitmap(decodedImage, orientation)
  }
  
  public init(uiImage: UIImage) {
    self._storage = .opaque(uiImage)
  }
  
  public var totalByteSize: Int {
    switch _storage {
    case .bitmap(let cgImage, _):
      return cgImage.bytesPerRow * cgImage.height
    case .opaque(let uiImage):
      guard let cgImage = uiImage.cgImage else {
        return 0
      }
      return cgImage.bytesPerRow * cgImage.height
    }
  }
  
  public func asUIImage() -> UIImage {
    switch _storage {
    case .bitmap(let cgImage, let orientation):
      return UIImage(cgImage: cgImage, scale: MAIN_SCREEN_SCALE, orientation: UIImage.Orientation(orientation))
    case .opaque(let uiImage):
      return uiImage
    }
  }
  
}

