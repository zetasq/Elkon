//
//  ImageViewBox.swift
//  Elkon
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIImageView {
  
  public final var elkon: ImageViewBox {
    return ImageViewBox(self)
  }
  
}

public struct ImageViewBox {
  
  internal let imageView: UIImageView
  
  internal init(_ imageView: UIImageView) {
    self.imageView = imageView
  }
  
  public func loadImage(at url: URL?, placeholder: UIImage? = nil, animated: Bool = true) {
    imageView._loadImage(at: url, placeholder: placeholder, animated: animated)
  }
  
  public func loadImage(named imageName: String, bundle: Bundle = .main, animated: Bool = true) {
    imageView._loadImage(named: imageName, bundle: bundle, animated: animated)
  }
  
  public func load(image: UIImage?, animated: Bool = true) {
    imageView._load(image: image, animated: animated)
  }
  
}

