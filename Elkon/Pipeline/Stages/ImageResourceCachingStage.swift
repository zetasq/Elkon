//
//  TypedImageCachingStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/18.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import SwiftCache

public final class ImageResourceCachingStage: ImagePipelineStageProtocol {
  
  public typealias OutputKeyType = URL
  
  public typealias OutputDataType = ImageResource
  

  public var nextStage: AnyImagePipelineStage<URL, ImageResource>? = nil
  
  private let _resourceCache: SwiftMemoryCache<String, ImageResource>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty")

    // TODO: Adjust cost limit and cache limit according to memory size
    self._resourceCache = .init(
      cacheName: "\(label).\(ImageResourceCachingStage.self).com.zetasq.Elkon",
      costLimit: 100 * 1024 * 1024,
      ageLimit: 30 * 24 * 60 * 60
    )
  }
  
  public func transformOutputKeyToInputKey(_ outputKey: URL) -> URL {
    return outputKey
  }
  
  public func searchDataAtThisStage(key: URL, completion: @escaping (ImageResource?) -> Void) {
    let cachedImage = _resourceCache.fetchObject(forKey: key.absoluteString)
    completion(cachedImage)
  }
  
  public func processDataFromNextStage(
    inputKey: URL,
    inputData: ImageResource,
    outputKey: URL,
    completion: @escaping (ImageResource?) -> Void)
  {
    _resourceCache.setObject(inputData, forKey: outputKey.absoluteString, cost: inputData.totalByteSize)
    completion(inputData)
  }
  
}
