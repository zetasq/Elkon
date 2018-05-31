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
  
  public var nextStage: AnyImagePipelineStage<Data>?

  private let imageDataCache: SwiftDiskCache<Data>
  
  public init(label: String) {
    assert(!label.isEmpty, "label should not be empty, it will be used to create cache directory")

    // TODO: Adjust cost limit and cache limit according to memory size
    self.imageDataCache = .init(
      cacheName: "\(label).\(RawImageDataCachingStage.self).com.zetasq.Elkon",
      byteLimit: 100 * 1024 * 1024,
      ageLimit: 30 * 24 * 60 * 60,
      objectEncoder: { $0 }, 
      objectDecoder: { $0 }
    )
  }
  
  public func searchDataAtThisStage(for url: URL, completion: @escaping (Data?) -> Void) {
    imageDataCache.asyncFetchObject(forKey: url.absoluteString) { data in
      completion(data)
    }
  }
  
  public func processDataFromNextStage(url: URL, data: Data, completion: @escaping (Data?) -> Void) {
    imageDataCache.asyncSetObject(data, forKey: url.absoluteString)
    completion(data)
  }
  
}
