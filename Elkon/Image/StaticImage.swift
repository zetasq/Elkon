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
    case cgImage(CGImage, CGImagePropertyOrientation)
    case uiImage(UIImage)
  }
  
  private let _storage: _Storage
  
  public init?(data: Data, renderConfig: ImageRenderConfig?) {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
      os_log("%@", log: StaticImage.logger, type: .error, "Failed to create CGImageSource with data")
      return nil
    }
    
    let imageOptions: CFDictionary
    if let config = renderConfig {
      imageOptions = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceShouldCacheImmediately: false,
        kCGImageSourceThumbnailMaxPixelSize: max(config.pixelSize.width, config.pixelSize.height)
      ] as CFDictionary
    } else {
      imageOptions = [
        kCGImageSourceShouldCacheImmediately: false,
        ] as CFDictionary
    }
    
    guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, imageOptions) else {
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
    
    self._storage = .cgImage(cgImage.predrawnImage(with: renderConfig), orientation)
  }
  
  public init(uiImage: UIImage) {
    self._storage = .uiImage(uiImage)
  }
  
  public var totalByteSize: Int {
    switch _storage {
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
    switch _storage {
    case .cgImage(let cgImage, let orientation):
      return UIImage(cgImage: cgImage, scale: scale, orientation: UIImageOrientation(orientation))
    case .uiImage(let uiImage):
      return uiImage
    }
  }
  
}

