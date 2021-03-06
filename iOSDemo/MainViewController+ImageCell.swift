//
//  MainViewController+ImageCell.swift
//  iOSDemo
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit
import SwiftLayout
import Elkon

extension MainViewController {
  
  final class ImageCell: UITableViewCell {
    
    private let iconView: ElkonImageView = {
      let iconView = ElkonImageView()
      
      iconView.contentMode = .scaleAspectFit
      iconView.layer.borderWidth = 1
      iconView.layer.borderColor = UIColor.green.cgColor
      iconView.layer.cornerRadius = 5
      
      return iconView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
      backgroundColor = .darkGray
      
      addSubview(iconView)
      iconView.slt.layout {
        $0.top == self.slt.top + 15
        $0.leading == self.slt.leading + 15
        $0.bottom == self.slt.bottom - 15
        $0.width == 50
        $0.height == 50
      }
    }
    
    func config(with url: URL) {
//      iconView.elkon.loadImage(at: url, animated: true)
      let config = ImageRenderConfig(sizeInPoints: CGSize(width: 50, height: 50), cornerRadiusInPoints: 5, scaleMode: .fill )
      iconView.elkon.loadImage(at: url, renderConfig: config, placeholder: nil, animated: true)
    }
    
  }
  
}
