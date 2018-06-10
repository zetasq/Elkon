//
//  ImageResource+Descriptor.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/6/9.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension ImageResource {
  
  public struct Descriptor: Hashable {

    var url: URL
    
    var renderConfig: ImageRenderConfig?
    
    public var hashValue: Int {
      return url.hashValue ^ (renderConfig?.hashValue ?? 0)
    }
    
  }
  
}
