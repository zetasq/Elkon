//
//  ImageTypeDecodingStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImageResourceDecodingStage: ImagePipelineStageProtocol {

  public typealias OutputKeyType = URL
  
  public typealias OutputDataType = ImageResource
  
  
  public var nextStage: AnyImagePipelineStage<URL, Data>?
  
  public func transformOutputKeyToInputKey(_ outputKey: URL) -> URL {
    return outputKey
  }
  
  public func searchDataAtThisStage(key: URL, completion: @escaping (ImageResource?) -> Void) {
    // We don't cache output at this stage
    completion(nil)
  }
  
  public func processDataFromNextStage(
    inputKey: URL,
    inputData: Data,
    outputKey: URL,
    completion: @escaping (ImageResource?) -> Void)
  {
    let image = ImageResource(data: inputData)
    completion(image)
  }
  
}

