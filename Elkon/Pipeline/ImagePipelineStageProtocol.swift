//
//  ImagePipelineStageProtocol.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol ImagePipelineStageProtocol: AnyObject, ImagePipelineStageOutputable {
  
  associatedtype InputType
  
  associatedtype OutputType

  var nextStage: AnyImagePipelineStage<InputType>? { get set }
  
  func searchDataAtThisStage(for url: URL, completion: @escaping (OutputType?) -> Void)
  
  func processDataFromNextStage(url: URL, data: InputType, completion: @escaping (OutputType?) -> Void)
  
}

extension ImagePipelineStageProtocol {
  
  public func configure<T: ImagePipelineStageProtocol>(withNextStage stage: T)
    where T.OutputType == Self.InputType {
    self.nextStage = AnyImagePipelineStage(stage: stage)
  }

  public func fetchDataWithRemainingPipeline(url: URL, completion: @escaping (OutputType?) -> Void) {
    searchDataAtThisStage(for: url) { cachedData in
      if let cachedData = cachedData {
        completion(cachedData)
        return
      }
      
      guard let nextStage = self.nextStage else {
        // This is the last stage of the pipeline
        completion(nil)
        return
      }
      
      nextStage.fetchDataWithRemainingPipeline(url: url) { dataFromNextStage in
        guard let dataFromNextStage = dataFromNextStage else {
          completion(nil)
          return
        }
        
        self.processDataFromNextStage(url: url, data: dataFromNextStage) { processedData in
          completion(processedData)
        }
      }
    }

  }
  
}
