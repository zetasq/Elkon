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
  
  func searchDataAtCurrentStage(key: OutputKeyType, task: ImagePipelineFetchingTask, completion: @escaping (OutputDataType?) -> Void)
  
  func processDataFromNextStage(
    inputKey: InputKeyType,
    inputData: InputDataType,
    outputKey: OutputKeyType,
    task: ImagePipelineFetchingTask,
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

  public func fetchDataWithRemainingPipeline(key: OutputKeyType, task: ImagePipelineFetchingTask, completion: ((OutputDataType?) -> Void)?) {
    guard !task.isCanceled else {
      completion?(nil)
      return
    }
    
    searchDataAtCurrentStage(key: key, task: task) { cachedData in
      if let cachedData = cachedData {
        completion?(cachedData)
        return
      }
      
      guard let nextStage = self.nextStage else {
        // This is the last stage of the pipeline
        completion?(nil)
        return
      }
      
      let inputKey = self.transformOutputKeyToInputKey(key)
      
      nextStage.fetchDataWithRemainingPipeline(key: inputKey, task: task) { dataFromNextStage in
        guard let dataFromNextStage = dataFromNextStage else {
          completion?(nil)
          return
        }
        
        // let the stage object to handle if the task is cancelled. We'd better cache the data downloaded even the task is canceled
        self.processDataFromNextStage(inputKey: inputKey, inputData: dataFromNextStage, outputKey: key, task: task) { processedData in
          completion?(processedData)
        }
      }
    }

  }
  
}
