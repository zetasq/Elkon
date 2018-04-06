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
  
  public func decodeToCGImage() -> CGImage? {
    let imageType = self.imageType
    
    switch imageType {
    case .PNG, .JPG:
      guard let imageSource = CGImageSourceCreateWithData(self as CFData, nil) else {
        os_log("%@", log: decodingLogger, type: .error, "Failed to create CGImageSource with data")
        return nil
      }
      return CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    default:
      os_log("%@", log: decodingLogger, type: .error, "Unsupported image type for decoding: \(imageType)")
      return nil
    }
  }
  
}

