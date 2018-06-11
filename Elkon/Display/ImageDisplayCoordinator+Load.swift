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
  
  private static var boundImageResourceDescriptorKey = "boundImageResourceDescriptorKey.com.zetasq.Elkon"
  
  private var currentBoundImageResourceDescriptor: ImageResource.Descriptor? {
    get {
      assert(Thread.isMainThread)
      
      return objc_getAssociatedObject(self, &ImageDisplayCoordinator.boundImageResourceDescriptorKey) as? ImageResource.Descriptor
    }
    set {
      assert(Thread.isMainThread)
      
      objc_setAssociatedObject(self, &ImageDisplayCoordinator.boundImageResourceDescriptorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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
    
    let newDescriptor = ImageResource.Descriptor(url: url, renderConfig: nil)
    guard currentBoundImageResourceDescriptor != newDescriptor else { return }
    
    currentBoundImageResourceDescriptor = newDescriptor
    
    setCurrentPlaceholderImage(placeholder, animated: animated)
    
    ImagePipeline.default.fetchImage(with: ImageResource.Descriptor(url: url, renderConfig: nil)) { [weak self] image in
      let block = {
        guard let `self` = self else {
          return
        }
        
        guard self.currentBoundImageResourceDescriptor == newDescriptor,
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
    
    let url = URL(string: "xcassets-store://\(bundle.bundleIdentifier!)/\(imageName)")! // This url is only for uniquelly identify the image
    let newDescriptor = ImageResource.Descriptor(url: url, renderConfig: nil)
    
    guard currentBoundImageResourceDescriptor != newDescriptor else { return }
    
    currentBoundImageResourceDescriptor = newDescriptor
    
    guard let uiImage = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
      os_log("%@", log: ImageDisplayCoordinator.logger, type: .error, "Failed to find image: name = \(imageName), bundle = \(bundle)")
      _setImageResource(nil, animated: animated)
      return
    }
    
    let imageResource = ImageResource(uiImage: uiImage)
    _setImageResource(imageResource, animated: animated)
  }
  
  public func load(uiImage: UIImage?, animated: Bool = true) {
    assert(Thread.isMainThread)
    
    currentBoundImageResourceDescriptor = nil
    
    guard let uiImage = uiImage else {
      _setImageResource(nil, animated: animated)
      return
    }
    
    let imageResource = ImageResource(uiImage: uiImage)
    _setImageResource(imageResource, animated: animated)
  }

}
