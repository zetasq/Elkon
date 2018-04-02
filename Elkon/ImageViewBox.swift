//
//  ImageViewBox.swift
//  Elkon
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

public struct ImageViewBox {
  
  internal let imageView: UIImageView
  
  internal init(_ imageView: UIImageView) {
    self.imageView = imageView
  }
  
}

extension UIImageView {
  
  public var elkon: ImageViewBox {
    return ImageViewBox(self)
  }
  
  private static var boundImageURLKey = "com.zetasq.Elkon.boundImageURLKey"
  
  internal var currentBoundImageURL: URL? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.boundImageURLKey) as? URL
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.boundImageURLKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  
}
