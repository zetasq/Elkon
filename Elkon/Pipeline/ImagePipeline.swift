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
      .bindNext(ImageResourceConstructingStage())
      .bindNext(RawImageDataCachingStage(label: "default"))
      .bindNext(ImageRetrievingStage())
    
    let pipeline = ImagePipeline(firstStage: typedImageCachingStage)
    return pipeline
  }()
  
  private let firstStage: AnyImagePipelineStage<ImageResource.Descriptor, ImageResource>
  
  public init<T: ImagePipelineStageProtocol>(firstStage: T)
    where T.OutputKeyType == ImageResource.Descriptor, T.OutputDataType == ImageResource {
    self.firstStage = AnyImagePipelineStage(stage: firstStage)
  }
  
  @discardableResult
  public func fetchImageResource(with descriptor: ImageResource.Descriptor, completion: @escaping (ImageResource?) -> Void) -> ImagePipelineFetchingTask  {
    let fetchingTask = ImagePipelineFetchingTask()
    
    firstStage.fetchDataWithRemainingPipeline(key: descriptor, task: fetchingTask, completion: completion)
    
    return fetchingTask
  }
  
}
