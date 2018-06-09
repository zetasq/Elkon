//
//  ImagePipeline.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation


public final class ImagePipeline {
  
  public static let `default`: ImagePipeline = {
    let typedImageCachingStage = ImageResourceCachingStage(label: "default")
    typedImageCachingStage
      .bindNext(ImageResourceDecodingStage())
      .bindNext(RawImageDataCachingStage(label: "default"))
      .bindNext(ImageRetrievingStage())
    
    let pipeline = ImagePipeline(firstStage: typedImageCachingStage)
    return pipeline
  }()
  
  private let firstStage: AnyImagePipelineStage<URL, ImageResource>
  
  public init<T: ImagePipelineStageProtocol>(firstStage: T)
    where T.OutputKeyType == URL, T.OutputDataType == ImageResource {
    self.firstStage = AnyImagePipelineStage(stage: firstStage)
  }
  
  public func fetchImage(with url: URL, completion: @escaping (ImageResource?) -> Void) {
    firstStage.fetchDataWithRemainingPipeline(key: url, completion: completion)
  }
  
}
