//
//  ImageDisplayCoordinator+Public.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/19.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

extension ImageDisplayCoordinator {
  
  private static var boundImageURLKey = "boundImageURLKey.com.zetasq.Elkon"
  
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
  
  public func loadImage(at url: URL?, placeholder: UIImage? = nil, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    guard let url = url else {
      load(uiImage: placeholder, animated: animated)
      return
    }
    
    guard url.scheme != "xcassets" else {
      // If the scheme is xcassets, we treat the host has the image name in the assets
      loadUIImage(named: url.host!, animated: animated)
      return
    }
    
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    
    setCurrentPlaceholderImage(placeholder, animated: animated)
    
    ImagePipeline.default.fetchImage(with: url) { [weak self] image in
      let block = {
        guard let `self` = self else {
          return
        }
        
        guard self.currentBoundImageURL == url,
          let image = image else {
            return
        }
        
        self._setImageResource(image, animated: animated)
      }
      
      if Thread.isMainThread {
        block()
      } else {
        DispatchQueue.main.async(execute: block)
      }
    }
  }
  
  public func loadUIImage(named imageName: String, bundle: Bundle = .main, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    let url = URL(string: "xcassets-store://\(bundle.bundleIdentifier!)/\(imageName)") // This url is only for uniquelly identify the image
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    
    guard let uiImage = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
      os_log("%@", log: ImageDisplayCoordinator.logger, type: .error, "Failed to find image: name = \(imageName), bundle = \(bundle)")
      _setImageResource(nil, animated: animated)
      return
    }
    
    _setImageResource(.static(.uiImage(uiImage)), animated: animated)
  }
  
  public func load(uiImage: UIImage?, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    currentBoundImageURL = nil
    
    guard let uiImage = uiImage else {
      _setImageResource(nil, animated: animated)
      return
    }
    
    _setImageResource(.static(.uiImage(uiImage)), animated: animated)
  }

}
