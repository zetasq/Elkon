//
//  ImageDisplayCoordinator.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/19.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit
import os.log

public final class ImageDisplayCoordinator {
  
  internal static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageDisplayCoordinator")
  
  internal weak var imageView: UIImageView?
  
  internal init(imageView: UIImageView) {
    assert(Thread.isMainThread)
    
    self.imageView = imageView
  }

  internal func _setUIImage(_ uiImage: UIImage?, animated: Bool) {
    assert(Thread.isMainThread)
    
    guard let imageView = imageView else {
      return
    }
    
    if animated {
      UIView.transition(with: imageView,
                        duration: 0.25,
                        options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState],
                        animations: {
                          imageView.image = uiImage
      }, completion: nil)
    } else {
      imageView.image = uiImage
    }
  }
  
  internal func _setImageResource(_ imageResource: ImageResource?, animated: Bool) {
    assert(Thread.isMainThread)
    
    guard let imageView = imageView else {
      return
    }
    
    guard let image = imageResource else {
      _setUIImage(nil, animated: animated)
      return
    }
    
    switch image {
    case .static(let staticImage):
      let uiImage = staticImage.asUIImage(scale: imageView.contentScaleFactor)
      _setUIImage(uiImage, animated: animated)
    case .animated(let animatedImage):
      // TODO: Implement animated image loading
      break
    }
  }

  
}
