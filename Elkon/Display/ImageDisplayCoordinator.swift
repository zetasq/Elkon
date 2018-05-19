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
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageDisplayCoordinator")

  private static var boundImageURLKey = "boundImageURLKey.com.zetasq.Elkon"

  private weak var imageView: UIImageView?
  
  internal init(imageView: UIImageView) {
    assert(Thread.isMainThread)
    
    self.imageView = imageView
  }

  
  private var currentBoundImageURL: URL? {
    get {
      assert(Thread.isMainThread)
      
      return objc_getAssociatedObject(self, &ImageDisplayCoordinator.boundImageURLKey) as? URL
    }
    set {
      assert(Thread.isMainThread)
      
      objc_setAssociatedObject(self, &ImageDisplayCoordinator.boundImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private func _setStaticImage(_ image: UIImage?, animated: Bool) {
    assert(Thread.isMainThread)
    
    guard let imageView = imageView else {
      return
    }
    
    if animated {
      UIView.transition(with: imageView,
                        duration: 0.25,
                        options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState],
                        animations: {
                          imageView.image = image
      }, completion: nil)
    } else {
      imageView.image = image
    }
  }
  
  public func loadImage(at url: URL?, placeholder: UIImage? = nil, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    guard let url = url else {
      load(image: placeholder, animated: animated)
      return
    }
    
    guard url.scheme != "xcassets" else {
      // If the scheme is xcassets, we treat the host has the image name in the assets
      loadImage(named: url.host!, animated: animated)
      return
    }
    
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    _setStaticImage(placeholder, animated: animated)
    
    ImagePipeline.default.fetchImage(with: url) { [weak self] image in
      DispatchQueue.main.async {
        guard let `self` = self, let imageView = self.imageView else {
            return
        }
        
        guard self.currentBoundImageURL == url,
          let image = image else {
            return
        }
        
        switch image {
        case .static(let staticImage):
          let uiImage = UIImage(cgImage: staticImage.cgImage, scale: imageView.contentScaleFactor, orientation: UIImageOrientation(staticImage.orientation))
          self._setStaticImage(uiImage, animated: animated)
        case .animated(_):
          // TODO: handle animated image
          break
        }
      }
    }
  }
  
  public func loadImage(named imageName: String, bundle: Bundle = .main, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    let url = URL(string: "xcassets://\(bundle.bundleIdentifier!)/\(imageName)") // This url is only for uniquelly identify the image
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    
    guard let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
      os_log("%@", log: ImageDisplayCoordinator.logger, type: .error, "Failed to find image: name = \(imageName), bundle = \(bundle)")
      _setStaticImage(nil, animated: animated)
      return
    }
    
    _setStaticImage(image, animated: animated)
  }
  
  public func load(image: UIImage?, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    currentBoundImageURL = nil
    _setStaticImage(image, animated: animated)
  }
  
}
