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
  
  public func loadImage(
    at url: URL?, 
    renderConfig: ImageRenderConfig? = nil, 
    placeholder: UIImage? = nil,
    animated: Bool = true)
  {
    assert(Thread.isMainThread)
    if let url = url {
      loadImage(with: .init(url: url, renderConfig: renderConfig), placeholder: placeholder, animated: animated)
    } else {
      loadImage(with: nil, placeholder: placeholder, animated: animated)
    }
  }
  
  public func loadImage(
    with descriptor: ImageResource.Descriptor?,  
    placeholder: UIImage? = nil,
    animated: Bool = true)
  {
    assert(Thread.isMainThread)
    
    guard let descriptor = descriptor else {
      currentBoundImageResourceDescriptor = nil
      
      setCurrentPlaceholderImage(placeholder)
      clearImageResource()
      
      return
    }
    
    guard currentBoundImageResourceDescriptor != descriptor else { return }
    currentBoundImageResourceDescriptor = descriptor
    
    setCurrentPlaceholderImage(placeholder)
    clearImageResource()
    
    ImagePipeline.default.fetchImageResource(with: descriptor) { [weak self] imageResource in
      let block = {
        guard let `self` = self else {
          return
        }
        
        guard self.currentBoundImageResourceDescriptor == descriptor else {
          return
        }
        
        guard let imageResource = imageResource else {
          return
        }
        
        self.setImageResource(imageResource, animated: animated)
      }
      
      if Thread.isMainThread {
        block()
      } else {
        DispatchQueue.main.async(execute: block)
      }
    }
  }
  
  public func load(
    uiImage: UIImage?, 
    placeholder: UIImage? = nil, 
    animated: Bool = true
    )
  {
    assert(Thread.isMainThread)
    
    currentBoundImageResourceDescriptor = nil
    
    setCurrentPlaceholderImage(placeholder)
    
    guard let uiImage = uiImage else {
      clearImageResource()
      return
    }
    
    let imageResource = ImageResource(uiImage: uiImage)
    setImageResource(imageResource, animated: animated)
  }

}
