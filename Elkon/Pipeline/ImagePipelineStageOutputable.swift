//
//  ImagePipelineStageOutputable.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/17.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public protocol ImagePipelineStageOutputable {
  
  associatedtype OutputKeyType: Hashable
  
  associatedtype OutputDataType
  
  func fetchDataWithRemainingPipeline(key: OutputKeyType, task: ImagePipelineFetchingTask, completion: ((OutputDataType?) -> Void)?)
  
}
