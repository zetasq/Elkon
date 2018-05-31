//
//  MainViewController.swift
//  iOSDemo
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit
import SwiftLayout

class MainViewController: UIViewController {
  
  private let imageURLs: [URL] = [
    URL(string: "https://via.placeholder.com/50x50")!,
    URL(string: "https://via.placeholder.com/50x100")!,
    URL(string: "https://via.placeholder.com/100x100")!,
    URL(string: "https://via.placeholder.com/100x150")!,
    URL(string: "https://via.placeholder.com/150x150")!,
    URL(string: "https://via.placeholder.com/150x200")!,
    URL(string: "https://media.giphy.com/media/QeuIjgyfsHp6w/giphy.gif")!,
    URL(string: "https://media.giphy.com/media/a9A3HLylBz2yA/giphy.gif")!,
  ]
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    
    tableView.dataSource = self
    tableView.register(ImageCell.self, forCellReuseIdentifier: "ImageCell")
    
    return tableView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }

  private func setupUI() {
    view.backgroundColor = .white
    
    view.addSubview(tableView)
    tableView.slt.layout {
      $0.top == view.slt.top
      $0.leading == view.slt.leading
      $0.bottom == view.slt.bottom
      $0.trailing == view.slt.trailing
    }
  }
}

extension MainViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return imageURLs.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
    
    imageCell.config(with: imageURLs[indexPath.row])
    
    return imageCell
  }
  
}
