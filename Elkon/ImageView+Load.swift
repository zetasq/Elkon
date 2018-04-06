//
//  ImageView+Load.swift
//  Elkon
//
//  Created by Zhu Shengqi on 3/4/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit
import os.log

extension UIImageView {
  
  private static let elkonLogger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageView")
  
  private static var boundImageURLKey = "com.zetasq.Elkon.boundImageURLKey"
  
  private var currentBoundImageURL: URL? {
    get {
      assert(Thread.isMainThread)
      
      return objc_getAssociatedObject(self, &UIImageView.boundImageURLKey) as? URL
    }
    set {
      assert(Thread.isMainThread)
      
      objc_setAssociatedObject(self, &UIImageView.boundImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private func _setStaticImage(_ image: UIImage?, animated: Bool) {
    assert(Thread.isMainThread)
    
    if animated {
      UIView.transition(with: self,
                        duration: 0.25, 
                        options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState],
                        animations: { 
                          self.image = image
      }, completion: nil)
    } else {
      self.image = image
    }
  }
  
  internal func _loadImage(at url: URL, animated: Bool = true, placeholder: UIImage? = nil) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?._loadImage(at: url, animated: animated, placeholder: placeholder)
      }
      return
    }
    
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    _setStaticImage(placeholder, animated: animated)
    
    ImageDataManager.default.fetchPredrawnImage(at: url) { [weak self] predrawnImage in
      DispatchQueue.main.async {
        guard let `self` = self else { return }
        
        guard self.currentBoundImageURL == url,
          let predrawnImage = predrawnImage else {
            return
        }
        
        let uiImage = UIImage(cgImage: predrawnImage, scale: self.contentScaleFactor, orientation: .up)
        self._setStaticImage(uiImage, animated: animated)
      }
    }
  }
  
  internal func _loadImage(named imageName: String, bundle: Bundle = .main, animated: Bool = true) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?._loadImage(named: imageName, bundle: bundle, animated: animated)
      }
      return
    }
    
    let url = URL(string: "xcassets://\(bundle.bundleIdentifier!)/\(imageName)") // This url is only for uniquelly identify the image
    guard currentBoundImageURL != url else { return }
    
    currentBoundImageURL = url
    
    guard let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
      os_log("%@", log: UIImageView.elkonLogger, type: .error, "Failed to find image: name = \(imageName), bundle = \(bundle)")
      _setStaticImage(nil, animated: animated)
      return
    }
    
    _setStaticImage(image, animated: animated)
  }
  
  internal func _load(image: UIImage?, animated: Bool = true) {
    guard Thread.isMainThread else {
      DispatchQueue.main.async { [weak self] in
        self?._load(image: image, animated: animated)
      }
      return
    }
    
    currentBoundImageURL = nil
    _setStaticImage(image, animated: animated)
  }
  
}
