//
//  WebPFrameInfo.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/2.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal struct WebPFrameInfo {
  
  /// 0-based index
  internal var frameIndex: Int
  
  /// In the Quartz2D coordinator system, where the origin is at the lower-left corner
  internal var frameRect: CGRect
  
  internal var disposeToBackground: Bool
  
  internal var blendWithPreviousFrame: Bool
  
  internal var hasAlpha: Bool
  
}
