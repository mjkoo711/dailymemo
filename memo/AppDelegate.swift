//
//  AppDelegate.swift
//  memo
//
//  Created by MinJun KOO on 25/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let appId = Const.appId
    FirebaseApp.configure()
    GADMobileAds.configure(withApplicationID: appId)
  
    setIQKeyboardPreference()
    setUNUserNotification()
    FMDBManager.shared.createDatabase()
    FMDBManager.shared.createDatabaseCompleted()
    initSetting()
    setNavigationbarTheme()
    return true
  }

  private func setNavigationbarTheme() {
    guard let theme = SettingManager.shared.theme else { return }
    if theme == .blackRed {
      UINavigationBar.appearance().tintColor = Color.LightRed
    } else if theme == .blackBlue {
      UINavigationBar.appearance().tintColor = Color.Blue
    }
  }

  private func setIQKeyboardPreference() {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
    IQKeyboardManager.shared.enableAutoToolbar = false
    IQKeyboardManager.shared.keyboardDistanceFromTextField = 8
  }

  private func setUNUserNotification() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (authorized, error) in
      if !authorized {print("App is useless becase you did not allow notification")
      }
    })

    let HollowAction = UNNotificationAction(identifier: "addHellow", title: "Hellow", options: [])
    let ByeAction = UNNotificationAction(identifier: "addBye", title: "Bye", options: [])

    let category = UNNotificationCategory(identifier: "eduCategory", actions: [HollowAction, ByeAction], intentIdentifiers: [], options: [])

    UNUserNotificationCenter.current().setNotificationCategories([category])
    UNUserNotificationCenter.current().delegate = self
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

    if response.actionIdentifier == "addHellow" {
      print("Say Hellow!")
    } else {
      print("Say Bye~")
    }
  }

  private func initSetting() {
    if let value = UserDefaults.standard.loadSettings(key: Key.Theme) {
      SettingManager.shared.setTheme(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 0, key: Key.Theme)
      SettingManager.shared.setTheme(value: 0)
    }

    if let value = UserDefaults.standard.loadSettings(key: Key.FontSize) {
      SettingManager.shared.setFontSize(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 1, key: Key.FontSize)
      SettingManager.shared.setFontSize(value: 1)

    }

    if let value = UserDefaults.standard.loadSettings(key: Key.FontWeight) {
      SettingManager.shared.setFontWeight(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 1, key: Key.FontWeight)
      SettingManager.shared.setFontWeight(value: 1)
    }

    if let value = UserDefaults.standard.loadSettings(key: Key.Vibrate) {
      SettingManager.shared.setVibration(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 1, key: Key.Vibrate)
      SettingManager.shared.setVibration(value: 1)
    }

    if let _ = UserDefaults.standard.loadSettings(key: Key.LockFeature) {
      // TODO
    } else {
      UserDefaults.standard.saveSettings(value: 0, key: Key.LockFeature)
      //TODO: set
    }

    if let value = UserDefaults.standard.loadSettings(key: Key.LineBreak) {
      SettingManager.shared.setLineBreak(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 1, key: Key.LineBreak)
      SettingManager.shared.setLineBreak(value: 1)
    }

    if let value = UserDefaults.standard.loadSettings(key: Key.CalendarMode) {
      SettingManager.shared.setCalendarMode(value: value)
    } else {
      UserDefaults.standard.saveSettings(value: 1, key: Key.CalendarMode)
      SettingManager.shared.setCalendarMode(value: 1)
    }
  }

  func applicationWillResignActive(_ application: UIApplication) { }

  func applicationDidEnterBackground(_ application: UIApplication) { }

  func applicationWillEnterForeground(_ application: UIApplication) {
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "ReloadCollectionView"),
      object: nil)
  }

  func applicationDidBecomeActive(_ application: UIApplication) { }

  func applicationWillTerminate(_ application: UIApplication) { }
}

