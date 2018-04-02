//
//  ImageViewBox+Load.swift
//  Elkon
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension ImageViewBox {
  

  public func loadImage(at url: URL, placeholder: UIImage? = nil) {
    guard imageView.currentBoundImageURL != url else { return }
    
    imageView.currentBoundImageURL = url
    imageView.image = placeholder
    
    ImageDataManager.default.fetchImageData(at: url) { [weak imageView] imageData in
      guard let `imageView` = imageView else { return }
      
      DispatchQueue.main.async { [weak imageView] in
        guard let `imageView` = imageView else { return }
        
        guard imageView.currentBoundImageURL == url else {
          return
        }
        
        guard let imageData = imageData else {
          return
        }
        
        guard let decodedImage = imageData.decodeAsUIImageForDisplay() else {
          return
        }
        
        imageView.image = decodedImage
      }
    }
  }
  
  public func clearImage() {
    imageView.currentBoundImageURL = nil
    imageView.image = nil
  }
  
}
