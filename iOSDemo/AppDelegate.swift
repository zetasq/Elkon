//
//  AppDelegate.swift
//  iOSDemo
//
//  Created by Zhu Shengqi on 02/04/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let mainWindow = UIWindow()
    self.window = mainWindow
    
    let navigationController = UINavigationController(rootViewController: MainViewController())
    mainWindow.rootViewController = navigationController
    
    mainWindow.makeKeyAndVisible()

    return true
  }

}

