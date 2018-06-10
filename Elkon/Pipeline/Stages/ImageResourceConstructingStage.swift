//
//  ImageTypeDecodingStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImageResourceConstructingStage: ImagePipelineStageProtocol {

  public typealias OutputKeyType = ImageResource.Descriptor
  
  public typealias OutputDataType = ImageResource
  
  public var nextStage: AnyImagePipelineStage<URL, Data>?
  
  public func transformOutputKeyToInputKey(_ outputKey: ImageResource.Descriptor) -> URL {
    return outputKey.url
  }
  
  public func searchDataAtThisStage(key: ImageResource.Descriptor, completion: @escaping (ImageResource?) -> Void) {
    // We don't cache output at this stage
    completion(nil)
  }
  
  public func processDataFromNextStage(
    inputKey: URL,
    inputData: Data,
    outputKey: ImageResource.Descriptor,
    completion: @escaping (ImageResource?) -> Void)
  {
    let image = ImageResource(data: inputData, renderConfig: outputKey.renderConfig)
    completion(image)
  }
  
}

