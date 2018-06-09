//
//  ImagePipelineStageProtocol.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol ImagePipelineStageProtocol: AnyObject, ImagePipelineStageOutputable {
  
  associatedtype InputKeyType: Hashable
  
  associatedtype InputDataType

  var nextStage: AnyImagePipelineStage<InputKeyType, InputDataType>? { get set }
  
  func transformOutputKeyToInputKey(_ outputKey: OutputKeyType) -> InputKeyType
  
  func searchDataAtThisStage(key: OutputKeyType, completion: @escaping (OutputDataType?) -> Void)
  
  func processDataFromNextStage(
    inputKey: InputKeyType,
    inputData: InputDataType,
    outputKey: OutputKeyType,
    completion: @escaping (OutputDataType?) -> Void
  )
  
}

extension ImagePipelineStageProtocol {
  
  @discardableResult
  public func bindNext<T: ImagePipelineStageProtocol>(_ stage: T) -> T
    where T.OutputKeyType == Self.InputKeyType, T.OutputDataType == Self.InputDataType {
      self.nextStage = AnyImagePipelineStage(stage: stage)
      return stage
  }

  public func fetchDataWithRemainingPipeline(key: OutputKeyType, completion: @escaping (OutputDataType?) -> Void) {
    searchDataAtThisStage(key: key) { cachedData in
      if let cachedData = cachedData {
        completion(cachedData)
        return
      }
      
      guard let nextStage = self.nextStage else {
        // This is the last stage of the pipeline
        completion(nil)
        return
      }
      
      let inputKey = self.transformOutputKeyToInputKey(key)
      
      nextStage.fetchDataWithRemainingPipeline(key: inputKey) { dataFromNextStage in
        guard let dataFromNextStage = dataFromNextStage else {
          completion(nil)
          return
        }
        
        self.processDataFromNextStage(inputKey: inputKey, inputData: dataFromNextStage, outputKey: key) { processedData in
          completion(processedData)
        }
      }
    }

  }
  
}
