//
//  AnyImagePipelineStage.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/18.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public struct AnyImagePipelineStage<OutputType>: ImagePipelineStageOutputable {
  
  private let fetchMethod: (URL, @escaping (OutputType?) -> Void) -> Void
  
  public init<T: ImagePipelineStageProtocol>(stage: T)
    where T.OutputType == OutputType {
      self.fetchMethod = stage.fetchDataWithRemainingPipeline
  }
  
  public func fetchDataWithRemainingPipeline(url: URL, completion: @escaping (OutputType?) -> Void) {
    self.fetchMethod(url, completion)
  }
  
}
