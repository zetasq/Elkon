//
//  ImageType.swift
//  Elkon
//
//  Created by Zhu Shengqi on 31/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import CWebP

public enum ImageType {
  case unknown
  case PNG
  case JPG
  case GIF
  case WebP
}

extension Data {
  
  public var imageType: ImageType {
    guard self.count >= 12 else {
      return .unknown
    }
    
    return self.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) -> ImageType in
      switch (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7], bytes[8], bytes[9], bytes[10], bytes[11]) {
      case (0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _, _, _, _):
        return .PNG
      case (0xFF, 0xd8, 0xFF, _, _, _, _, _, _, _, _, _):
        return .JPG
      case (0x47, 0x49, 0x46, _, _, _, _, _, _, _, _, _): // 'G', 'I', 'F'
        return .GIF
      case (0x52, 0x49, 0x46, 0x46, _, _, _, _, 0x57, 0x45, 0x42, 0x50): // 'R', 'I', 'F', 'F', _, _, _, _, 'W', 'E', 'B', 'P'
        return .WebP
      default:
        return .unknown
      }
    }
  }
  
}

