//
//  ElkonImageView.swift
//  Elkon
//
//  Created by Zhu Shengqi on 2018/5/24.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

public final class ElkonImageView: UIImageView {
  
  public private(set) lazy var elkon: ImageDisplayCoordinator = {
    assert(Thread.isMainThread)
    let coordinator = ImageDisplayCoordinator(imageView: self)
    return coordinator
  }()
  
}
