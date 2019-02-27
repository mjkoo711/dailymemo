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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    setIQKeyboardPreference()
    setUNUserNotification()

    return true
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
    }else{
      print("Say Bye~")
    }
  }


  func showEduNotification(textSelected: Text, datePicked: Date, notificationType: NotificationType){

    let content = UNMutableNotificationContent()
    content.body = textSelected.string
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "eduCategory"
    var trigger: UNCalendarNotificationTrigger!

    switch notificationType {
    case .Daily:
      let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
    case .Once:
      let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
    case .Weekly:
      let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,.second,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
    case .Monthly:
      let triggerWeekly = Calendar.current.dateComponents([.month,.weekday,.hour,.minute,.second,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
    }

    let request = UNNotificationRequest(identifier: textSelected.createdAt, content: content, trigger: trigger)
//    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    // TODO: 알람 개별지우기(알람설정했으면 ㅎ), 전체지우기
    UNUserNotificationCenter.current().add(request){ (error) in
      if let error = error {
        print("Error:\(error.localizedDescription)")
      }
    }
  }


  func applicationWillResignActive(_ application: UIApplication) { }

  func applicationDidEnterBackground(_ application: UIApplication) { }

  func applicationWillEnterForeground(_ application: UIApplication) { }

  func applicationDidBecomeActive(_ application: UIApplication) { }

  func applicationWillTerminate(_ application: UIApplication) { }
}

