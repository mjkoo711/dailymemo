//
//  AlarmManager.swift
//  memo
//
//  Created by MinJun KOO on 28/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UserNotifications

class AlarmManager {
  func modifyNotification(textSelected: Text, notificationType: NotificationType){

    let content = UNMutableNotificationContent()
    content.body = textSelected.string
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "eduCategory"
    var trigger: UNCalendarNotificationTrigger!

    switch notificationType {
    case .Once:
      let triggerDaily = Calendar.current.dateComponents([.hour,.minute,], from: textSelected.alarmDatePicked!)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
    case .Daily: break

    case .Weekly: break

    case .Monthly: break

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

  func removeNotification(textSelected: Text) {
    var identifiers: [String] = []
    identifiers.append(textSelected.createdAt)

    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
  }


  func addNotification(textSelected: Text, datePicked: Date, notificationType: NotificationType){

    let content = UNMutableNotificationContent()
    content.body = textSelected.string
    content.sound = UNNotificationSound.default
    content.categoryIdentifier = "eduCategory"
    var trigger: UNCalendarNotificationTrigger!

    switch notificationType {
    case .Daily:
      let triggerDaily = Calendar.current.dateComponents([.hour,.minute,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
    case .Once:
      let triggerDaily = Calendar.current.dateComponents([.hour,.minute,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: false)
    case .Weekly:
      let triggerWeekly = Calendar.current.dateComponents([.weekday,.hour,.minute,], from: datePicked)
      trigger = UNCalendarNotificationTrigger(dateMatching: triggerWeekly, repeats: true)
    case .Monthly:
      let triggerWeekly = Calendar.current.dateComponents([.month,.weekday,.hour,.minute,], from: datePicked)
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

}
