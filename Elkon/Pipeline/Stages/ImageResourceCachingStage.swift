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

  public var nextStage: AnyImagePipelineStage<ImageResource>? = nil
  
  private let imageCache: SwiftMemoryCache<ImageResource>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty")

    // TODO: Adjust cost limit and cache limit according to memory size
    self.imageCache = .init(
      cacheName: "\(label).\(ImageResourceCachingStage.self).com.zetasq.Elkon",
      costLimit: 100 * 1024 * 1024,
      ageLimit: 30 * 24 * 60 * 60
    )
  }
  
  public func searchDataAtThisStage(for url: URL, completion: @escaping (ImageResource?) -> Void) {
    let cachedImage = imageCache.fetchObject(forKey: url.absoluteString)
    completion(cachedImage)
  }
  
  public func processDataFromNextStage(url: URL, data: ImageResource, completion: @escaping (ImageResource?) -> Void) {
    imageCache.setObject(data, forKey: url.absoluteString, cost: data.totalByteSize)
    completion(data)
  }
  
}
