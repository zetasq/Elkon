//
//  RawImageDataCacher.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import SwiftCache

public final class RawImageDataCachingStage: ImagePipelineStageProtocol {
  
  public typealias OutputKeyType = URL
  
  public typealias OutputDataType = Data
  
  public var nextStage: AnyImagePipelineStage<URL, Data>?

  private let _imageDataCache: SwiftDiskCache<Data>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty, it will be used to create cache directory")
    
    self._imageDataCache = .init(
      cacheName: "\(label).\(RawImageDataCachingStage.self).com.zetasq.Elkon",
      byteLimit: 100 * 1024 * 1024,
      ageLimit: 30 * 24 * 60 * 60,
      objectEncoder: { $0 }, 
      objectDecoder: { $0 }
    )
  }
  
  public func transformOutputKeyToInputKey(_ outputKey: URL) -> URL {
    return outputKey
  }
  
  public func searchDataAtCurrentStage(key: URL, task: ImagePipelineFetchingTask, completion: @escaping (Data?) -> Void) {
    _imageDataCache.asyncFetchObject(forKey: key.absoluteString) { data in
      completion(data)
    }
  }
  
  public func processDataFromNextStage(
    inputKey: URL,
    inputData: Data,
    outputKey: URL,
    task: ImagePipelineFetchingTask,
    completion: @escaping (Data?) -> Void)
  {
    _imageDataCache.asyncSetObject(inputData, forKey: outputKey.absoluteString)
    completion(inputData)
  }

}
