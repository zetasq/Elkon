//
//  ImageDownloadStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImageDownloadStage: ImagePipelineStageProtocol {

  public var nextStage: AnyImagePipelineStage<Void>? = nil // This should be the last stage of the image pipeline
  
  private var _urlToDownloadTaskTable: [URL: ImageDownloadTask] = [:]
  private var _tableLock = os_unfair_lock_s()
  
  public func searchDataAtThisStage(for url: URL, completion: @escaping (Data?) -> Void) {
    os_unfair_lock_lock(&_tableLock)
    defer {
      os_unfair_lock_unlock(&_tableLock)
    }
    
    let imageDownloadTask: ImageDownloadTask
    
    if let existingTask = _urlToDownloadTaskTable[url] {
      imageDownloadTask = existingTask
    } else {
      imageDownloadTask = ImageDownloadTask(url: url)
      _urlToDownloadTaskTable[url] = imageDownloadTask
      
      imageDownloadTask.addFinishHandler { _ in
        os_unfair_lock_lock(&self._tableLock)
        defer {
          os_unfair_lock_unlock(&self._tableLock)
        }
        
        self._urlToDownloadTaskTable.removeValue(forKey: url)
      }
      
      imageDownloadTask.resume()
    }
    
    imageDownloadTask.addFinishHandler { data in
      completion(data)
    }
  }
  
  public func processDataFromNextStage(url: URL, data: Void, completion: @escaping (Data?) -> Void) {
    fatalError("\(type(of: self)) is the last working stage of the image pipeline, we don't expect data from next stage")
  }
  
}
