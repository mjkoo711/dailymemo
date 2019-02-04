//
//  AppDelegate.swift
//  memo
//
//  Created by MinJun KOO on 25/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 8
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) { }

  func applicationDidEnterBackground(_ application: UIApplication) { }

  func applicationWillEnterForeground(_ application: UIApplication) { }

  func applicationDidBecomeActive(_ application: UIApplication) { }

  func applicationWillTerminate(_ application: UIApplication) { }
}

