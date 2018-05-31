//
//  ElkonImageView.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/24.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

public final class ElkonImageView: UIImageView {
  
  public final private(set) lazy var elkon: ImageDisplayCoordinator = {
    assert(Thread.isMainThread)
    let coordinator = ImageDisplayCoordinator(imageView: self)
    return coordinator
  }()
  
  
  /// This property supports UIAppearance
  @objc
  dynamic
  public var defaultPlaceholderImage: UIImage? {
    get {
      return elkon.defaultPlaceholderImage
    }
    set {
      elkon.defaultPlaceholderImage = newValue
    }
  }
  
  public override var isHighlighted: Bool {
    // TODO: if we have the animated image, highlighted should be false
    get {
      return super.isHighlighted
    }
    set {
      super.isHighlighted = newValue
    }
  }
  
  public override func didMoveToWindow() {
    super.didMoveToWindow()
    
    elkon.updateAnimatingStatus()
  }
  
  public override var alpha: CGFloat {
    didSet {
      elkon.updateAnimatingStatus()
    }
  }
  
  public override var isHidden: Bool {
    didSet {
      elkon.updateAnimatingStatus()
    }
  }
}
