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
  
  public var pixelSize: CGSize
  
  public var scaleMode: ScaleMode
  
  public var cornerRadius: CGFloat
  
  public var hashValue: Int {
    return pixelSize.width.hashValue ^ pixelSize.height.hashValue ^ scaleMode.hashValue ^ cornerRadius.hashValue
  }
  
}
