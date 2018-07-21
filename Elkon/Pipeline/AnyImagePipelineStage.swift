//
//  AnyImagePipelineStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/18.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public struct AnyImagePipelineStage<OutputKeyType: Hashable, OutputDataType>: ImagePipelineStageOutputable {
  
  private let fetchMethod: (OutputKeyType, ImagePipelineFetchingTask, ((OutputDataType?) -> Void)?) -> Void
  
  public init<T: ImagePipelineStageProtocol>(stage: T)
    where T.OutputKeyType == OutputKeyType, T.OutputDataType == OutputDataType {
      self.fetchMethod = stage.fetchDataWithRemainingPipeline
  }
  
  public func fetchDataWithRemainingPipeline(key: OutputKeyType, task: ImagePipelineFetchingTask, completion: ((OutputDataType?) -> Void)?) {
    self.fetchMethod(key, task, completion)
  }
  
}
