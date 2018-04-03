//
//  ImageView+Load.swift
//  Elkon
//
//  Created by Zhu Shengqi on 3/4/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

extension UIImageView {
  
  internal func _loadStaticImage(_ image: UIImage?, animated: Bool) {
    if animated {
      UIView.transition(with: self,
                        duration: 0.25, 
                        options: [.transitionCrossDissolve, .curveEaseInOut, .beginFromCurrentState
        ],
                        animations: { 
                          self.image = image
      }, completion: nil)
    } else {
      self.image = image
    }
  }
  
}
