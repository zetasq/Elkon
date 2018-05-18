//
//  StaticImage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public struct StaticImage {
  
  public let cgImage: CGImage
  
  public let orientation: CGImagePropertyOrientation
  
  public var totalByteSize: Int {
    return cgImage.bytesPerRow * cgImage.height
  }
  
}
