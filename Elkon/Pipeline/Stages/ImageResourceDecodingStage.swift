//
//  ImageTypeDecodingStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImageResourceDecodingStage: ImagePipelineStageProtocol {
  
  public var nextStage: AnyImagePipelineStage<Data>?
  
  public func searchDataAtThisStage(for url: URL, completion: @escaping (ImageResource?) -> Void) {
    // We don't cache output at this stage
    completion(nil)
  }
  
  public func processDataFromNextStage(url: URL, data: Data, completion: @escaping (ImageResource?) -> Void) {
    let image = ImageResource(data: data)
    completion(image)
  }
  
}

