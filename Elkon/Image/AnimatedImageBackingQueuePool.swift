//
//  AnimatedImageBackingQueuePool.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/9/19.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension AnimatedImage {
  
  internal enum AnimatedImageBackingQueuePool {
    
    private static let _imagePreparingQueues: [DispatchQueue] = {
      var queues: [DispatchQueue] = []
      
      for i in 0..<5 {
        let queue = DispatchQueue(
          label: "com.zetasq.Elkon.AnimatedImage.DispatchQueuePool.imagePreparingQueue-\(i)",
          qos: DispatchQoS.utility
        )
        
        queues.append(queue)
      }
      
      return queues
    }()
    
    internal static func randomImagePreparingQueue() -> DispatchQueue {
      return _imagePreparingQueues.randomElement()!
    }
    
    private static let _imageAccessingQueues: [DispatchQueue] = {
      var queues: [DispatchQueue] = []
      
      for i in 0..<5 {
        let queue = DispatchQueue(
          label: "com.zetasq.Elkon.AnimatedImage.DispatchQueuePool.imageAccessingQueue-\(i)",
          qos: DispatchQoS.userInteractive
        )
        
        queues.append(queue)
      }
      
      return queues
    }()
    
    internal static func randomImageAccessingQueue() -> DispatchQueue {
      return _imageAccessingQueues.randomElement()!
    }
    
  }
  
}
