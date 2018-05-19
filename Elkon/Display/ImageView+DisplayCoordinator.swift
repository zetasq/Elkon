//
//  ImageView+DisplayCoordinator.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/19.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIImageView {
  
  private static var displayCoordinatorKey = "displayCoordinatorKey.ImageView.com.zetasq.Elkon"
  
  public var elkon: ImageDisplayCoordinator {
    assert(Thread.isMainThread)
    
    if let existingCoordinator = objc_getAssociatedObject(self, &UIImageView.displayCoordinatorKey) as? ImageDisplayCoordinator {
      return existingCoordinator
    } else {
      let newCoordinator = ImageDisplayCoordinator(imageView: self)
      objc_setAssociatedObject(self, &UIImageView.displayCoordinatorKey, newCoordinator, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      return newCoordinator
    }
  }
  
}
