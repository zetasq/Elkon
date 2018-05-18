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
    let imageDownloadStage = ImageDownloadStage()
    
    let rawImageDataCachingStage = RawImageDataCachingStage(label: "default")
    rawImageDataCachingStage.configure(withNextStage: imageDownloadStage)
    
    let imageTypeDecodingStage = ImageTypeDecodingStage()
    imageTypeDecodingStage.configure(withNextStage: rawImageDataCachingStage)
    
    let typedImageCachingStage = TypedImageCachingStage(label: "default")
    typedImageCachingStage.configure(withNextStage: imageTypeDecodingStage)
    
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
