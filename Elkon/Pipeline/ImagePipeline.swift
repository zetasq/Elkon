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
    let typedImageCachingStage = TypedImageCachingStage(label: "default")
    typedImageCachingStage
      .bindNext(ImageTypeDecodingStage())
      .bindNext(RawImageDataCachingStage(label: "default"))
      .bindNext(ImageDownloadStage())
    
    let pipeline = ImagePipeline(firstStage: typedImageCachingStage)
    return pipeline
  }()
  
  private let firstStage: AnyImagePipelineStage<Image>
  
  public init<T: ImagePipelineStageProtocol>(firstStage: T)
    where T.OutputType == Image {
    self.firstStage = AnyImagePipelineStage(stage: firstStage)
  }
  
  public func fetchImage(with url: URL, completion: @escaping (Image?) -> Void) {
    firstStage.fetchDataWithRemainingPipeline(url: url, completion: completion)
  }
  
}
