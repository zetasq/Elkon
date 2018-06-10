//
//  PDFImageTestViewController.swift
//  iOSDemo
//
//  Created by Zhu Shengqi on 2018/6/10.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

final class PDFImageTestViewController: UIViewController {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    
    imageView.contentMode = .center
    
    return imageView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    view.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      imageView.widthAnchor.constraint(equalToConstant: 300),
      imageView.heightAnchor.constraint(equalToConstant: 300),
      ])
    
    
    let size = CGSize(width: 108, height: 108)
    UIGraphicsBeginImageContextWithOptions(size, false, 1)
    defer {
      UIGraphicsEndImageContext()
    }
    
    let context = UIGraphicsGetCurrentContext()!
    
    // Flip the context because UIKit coordinate system is upside down to Quartz coordinate system
    // https://developer.apple.com/library/content/qa/qa1708/_index.html
    
    context.translateBy(x: 0, y: 108)
    context.scaleBy(x: 1, y: -1)
    
    let uiImage = UIImage(named: "stickerEmojiOne")!
    let cgImage = uiImage.cgImage!
    
    context.draw(cgImage, in: CGRect(origin: .zero, size: CGSize(width: 108, height: 108)))
    
    let finalImage = context.makeImage()!
    let finalUIImage = UIImage(cgImage: finalImage, scale: UIScreen.main.scale, orientation: .up)
    
    imageView.image = finalUIImage
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
}
