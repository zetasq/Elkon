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
  
  internal func decodeAsUIImageForDisplay() -> UIImage? {
    let imageType = self.imageType
    
    switch imageType {
    case .PNG, .JPG:
      return UIImage(data: self, scale: UIScreen.main.scale)
    default:
      os_log("%@", log: decodingLogger, type: .error, "Unsupported image type for decoding: \(imageType)")
      return nil
    }
  }
  
}

