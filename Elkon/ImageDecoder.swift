//
//  ImageDecoder.swift
//  Elkon
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit
import os.log

private let decodingLogger = OSLog(subsystem: "com.zetasq.Elkon", category: "decoding")

extension Data {
  
  public func decodeToBitmapImage() -> BitmapImage? {
    let imageType = self.imageType
    
    switch imageType {
    case .PNG, .JPG:
      guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else {
        os_log("%@", log: decodingLogger, type: .error, "Failed to create CGImageSource with data")
        return nil
      }
      
      guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        os_log("%@", log: decodingLogger, type: .error, "Failed to create create image at index 0 from CGImageSource")
        return nil
      }
      
      let orientation: CGImagePropertyOrientation
      if let properties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any],
        let orientationValue = properties[kCGImagePropertyOrientation as String] as? UInt32 {
        orientation = CGImagePropertyOrientation(rawValue: orientationValue) ?? .up
      } else {
        orientation = .up
      }
      
      return BitmapImage(cgImage: cgImage.generateBitmapImage(), orientation: orientation)
    default:
      os_log("%@", log: decodingLogger, type: .error, "Unsupported image type for decoding: \(imageType)")
      return nil
    }
  }
  
}

