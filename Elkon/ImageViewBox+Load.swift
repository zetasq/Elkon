//
//  ImageViewBox+Load.swift
//  Elkon
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation
import os.log

extension ImageViewBox {
  
  private static let logger = OSLog(subsystem: "com.zetasq.Elkon", category: "ImageViewBox")
  
  public func loadImage(at url: URL, animated: Bool = true, placeholder: UIImage? = nil) {
    guard imageView.currentBoundImageURL != url else { return }
    
    imageView.currentBoundImageURL = url
    imageView._loadStaticImage(placeholder, animated: animated)
    
    ImageDataManager.default.fetchImageData(at: url) { [weak imageView] imageData in
      DispatchQueue.main.async {
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
        
        imageView._loadStaticImage(decodedImage, animated: animated)
      }
    }
  }
  
  public func loadImage(named imageName: String, bundle: Bundle = .main, animated: Bool = true) {
    let url = URL(string: "xcassets://\(bundle.bundleIdentifier!)/\(imageName)") // This url is only for uniquelly identify the image
    guard imageView.currentBoundImageURL != url else { return }
    
    imageView.currentBoundImageURL = url
    
    guard let image = UIImage(named: imageName, in: bundle, compatibleWith: nil) else {
      os_log("%@", log: ImageViewBox.logger, type: .error, "Failed to find image: name = \(imageName), bundle = \(bundle)")
      imageView._loadStaticImage(nil, animated: animated)
      return
    }
    
    imageView._loadStaticImage(image, animated: animated)
  }
  
  public func load(image: UIImage?, animated: Bool = true) {
    imageView.currentBoundImageURL = nil
    imageView._loadStaticImage(image, animated: animated)
  }
  
}
