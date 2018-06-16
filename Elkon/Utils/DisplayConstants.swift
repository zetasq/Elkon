//
//  DisplayConstants.swift
//  Elkon
//
//  Created by Zhu Shengqi on 11/6/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

public let MAIN_SCREEN_SCALE: CGFloat = {
  UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), true, 0)
  defer {
    UIGraphicsEndImageContext()
  }
  
  return UIGraphicsGetCurrentContext()!.ctm.a
}()
