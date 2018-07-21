//
//  ImagePipelineFetchingTask.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/7/21.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImagePipelineFetchingTask {
  
  private var _canceled = false
  
  private var _lock = os_unfair_lock_s()
  
  public var isCanceled: Bool {
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    return _canceled
  }
  
  public func cancel() {
    os_unfair_lock_lock(&_lock)
    defer {
      os_unfair_lock_unlock(&_lock)
    }
    
    _canceled = true
  }
  
}
