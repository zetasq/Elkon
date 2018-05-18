//
//  ImageTypeDecodingStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class ImageTypeDecodingStage: ImagePipelineStageProtocol {
  
  public var nextStage: AnyImagePipelineStage<Data>?
  
  public func searchDataAtThisStage(for url: URL, completion: @escaping (Image?) -> Void) {
    // We don't cache output at this stage
    completion(nil)
  }
  
  public func processDataFromNextStage(url: URL, data: Data, completion: @escaping (Image?) -> Void) {
    let image = Image(data: data)
    completion(image)
  }
  
}

