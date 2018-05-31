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
  
  // MARK: - Properties
  private weak var imageView: UIImageView?
  
  private var displayStack: ImageDisplayStack {
    didSet {
      imageView?.image = displayStack.currentDisplayImage ?? displayStack.currentPlaceholderImage ?? displayStack.defaultPlaceholderImage
    }
  }
  
  private var displayDriver: ImageDisplayDriverProtocol?
  
  // MARK: - Init & deinit
  internal init(imageView: UIImageView) {
    assert(Thread.isMainThread)
    
    self.imageView = imageView
    self.displayStack = ImageDisplayStack()
  }
  
  // MARK: - Internal interface for placeholder
  internal var defaultPlaceholderImage: UIImage? {
    get {
      return displayStack.defaultPlaceholderImage
    }
    set {
      displayStack.defaultPlaceholderImage = newValue
    }
  }
  
  internal var currentPlaceholderImage: UIImage? {
    get {
      return displayStack.currentPlaceholderImage
    }
    set {
      displayStack.currentPlaceholderImage = newValue
    }
  }
  
  internal func setCurrentPlaceholderImage(_ image: UIImage?, animated: Bool) {
    if animated {
      animateWithChange {
        self.displayStack.currentPlaceholderImage = image
      }
    } else {
      displayStack.currentPlaceholderImage = image
    }
  }
  
  // MARK: - Internal interface for loading ImageResource
  internal func _setImageResource(_ imageResource: ImageResource?, animated: Bool) {
    assert(Thread.isMainThread)
    
    guard let imageView = imageView else {
      return
    }
    
    displayDriver = ImageDisplayDriverMakeWithResource(imageResource, config: .init(imageScaleFactor: imageView.contentScaleFactor, shouldAnimate: animated))
    displayDriver?.delegate = self
    displayDriver?.startDisplay()

    updateAnimatingStatus()
  }
  
  // MARK: - Internal interface for ElkonImageView
  internal func updateAnimatingStatus() {
    guard let imageView = imageView else {
      return
    }
    
    isAnimating = imageView.window != nil && imageView.alpha > 0 && !imageView.isHidden
  }

  // MARK: - Helper methods
  private func animateWithChange(_ block: @escaping () -> Void) {
    guard let imageView = imageView else {
      block()
      return
    }
    
    UIView.transition(with: imageView,
                      duration: 0.25,
                      options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState],
                      animations: {
                        block()
    }, completion: nil)
  }
  
  private var isAnimating: Bool {
    get {
      guard let animatedImageDisplayDriver = displayDriver as? AnimatedImageDisplayDriver else {
        return false
      }
      return animatedImageDisplayDriver.isAnimating
    }
    set {
      guard let animatedImageDisplayDriver = displayDriver as? AnimatedImageDisplayDriver else {
        return
      }
      animatedImageDisplayDriver.isAnimating = newValue
    }
  }

}

// MARK: - ImageDisplayDriverDelegate
extension ImageDisplayCoordinator: ImageDisplayDriverDelegate {
  
  func imageDisplayDriverRequestDisplayingImage(_ driver: ImageDisplayDriverProtocol, image: UIImage?, animated: Bool) {
    guard driver === self.displayDriver else {
      return
    }
    
    if animated {
      animateWithChange {
        self.displayStack.currentDisplayImage = image
      }
    } else {
      self.displayStack.currentDisplayImage = image
    }
  }
  
}
