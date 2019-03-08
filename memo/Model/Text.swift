//
//  Text.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class Text: Codable {
  var string: String
  var date: String
  var time: String
  var day: String
  var createdAt: String
  var repeatMode: RepeatMode
  private(set) var isAlarmSetting: Bool
  var alarmDatePicked: Date?

  init(string: String, date: String, time: String, day: String, repeatMode: RepeatMode) {
    self.string = string
    self.date = date
    self.time = time
    self.day = day
    self.repeatMode = repeatMode
    self.createdAt = date + " " + time
    self.isAlarmSetting = false
  }

  func onAlarmSetting() {
    isAlarmSetting = true
  }

  func offAlarmSetting() {
    isAlarmSetting = false
  }
}
