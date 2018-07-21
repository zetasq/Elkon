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
  
  public typealias OutputKeyType = ImageResource.Descriptor
  
  public typealias OutputDataType = ImageResource

  public var nextStage: AnyImagePipelineStage<ImageResource.Descriptor, ImageResource>? = nil
  
  private let _resourceCache: SwiftMemoryCache<ImageResource.Descriptor, ImageResource>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty")

    let deviceMemorySize = ProcessInfo.processInfo.physicalMemory
    
    self._resourceCache = .init(
      cacheName: "\(label).\(ImageResourceCachingStage.self).com.zetasq.Elkon",
      costLimit: Int(deviceMemorySize / 10),
      ageLimit: 30 * 24 * 60 * 60
    )
  }
  
  public func transformOutputKeyToInputKey(_ outputKey: ImageResource.Descriptor) -> ImageResource.Descriptor {
    return outputKey
  }
  
  public func searchDataAtCurrentStage(key: ImageResource.Descriptor, task: ImagePipelineFetchingTask, completion: @escaping (ImageResource?) -> Void) {
    let cachedImage = _resourceCache.fetchObject(forKey: key)
    completion(cachedImage)
  }
  
  public func processDataFromNextStage(
    inputKey: ImageResource.Descriptor,
    inputData: ImageResource,
    outputKey: ImageResource.Descriptor,
    task: ImagePipelineFetchingTask,
    completion: @escaping (ImageResource?) -> Void)
  {
    _resourceCache.setObject(inputData, forKey: outputKey, cost: inputData.totalByteSize)
    completion(inputData)
  }
  
}
