//
//  ImageRenderConfig.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/9.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public struct ImageRenderConfig: Hashable {

  public enum ScaleMode: Hashable {
    
    case fit
    
    case fill
    
  }
  
  public var sizeInPoints: CGSize
    
  public var cornerRadiusInPoints: CGFloat
  
  public var scaleMode: ScaleMode
  
  public init(sizeInPoints: CGSize, cornerRadiusInPoints: CGFloat, scaleMode: ScaleMode) {
    self.sizeInPoints = sizeInPoints
    self.cornerRadiusInPoints = cornerRadiusInPoints
    self.scaleMode = scaleMode
  }
  
  public var maxDimensionInPixels: CGFloat {
    return max(sizeInPoints.width * MAIN_SCREEN_SCALE, sizeInPoints.height * MAIN_SCREEN_SCALE)
  }
  
  public var sizeInPixels: CGSize {
    return CGSize(
      width: sizeInPoints.width * MAIN_SCREEN_SCALE,
      height: sizeInPoints.height * MAIN_SCREEN_SCALE
    )
  }
  
  public var cornerRadiusInPixels: CGFloat {
    return cornerRadiusInPoints * MAIN_SCREEN_SCALE
  }
  
  public var needsToClipWithCornerRadius: Bool {
    return cornerRadiusInPoints > 0
  }
  
  public var hashValue: Int {
    return sizeInPoints.width.hashValue ^ sizeInPoints.height.hashValue ^ scaleMode.hashValue ^ cornerRadiusInPoints.hashValue
  }
  
}

