//
//  TextLoader.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class TextLoader {
  func findAlarmTextList() -> [Text] {
  let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE repeatmode = 0 and is_alarm_setting = 1 ORDER BY date"
  return FMDBManager.shared.selectTextList(sql: querySQL, likeQuery: nil)
  }

  func findOnceTextList(date: String) -> [Text] {
    let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE repeatmode = 0 and date = '\(date)'"
    return FMDBManager.shared.selectTextList(sql: querySQL, likeQuery: nil)
  }

  func findDailyTextList() -> [Text] {
    let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE repeatmode = 1"
    return FMDBManager.shared.selectTextList(sql: querySQL, likeQuery: nil)
  }

  func findWeeklyTextList(date: String) -> [Text] {
    let changer = DateStringChanger()
    let weekDay = changer.getDayOfWeek(date)

    let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE repeatmode = 2 and day = '\(changer.getStringDayOfWeek(weekDay: weekDay))'"
    return FMDBManager.shared.selectTextList(sql: querySQL, likeQuery: nil)
  }


  func findMonthlyTextList(date: String) -> [Text] {
    let subDate = date.components(separatedBy: "-")[2]
    let querySQL = "SELECT contents, date, time, day, repeatmode, is_alarm_setting, alarm_date FROM CONTACTS WHERE repeatmode = 3 and date like ?"
    return FMDBManager.shared.selectTextList(sql: querySQL, likeQuery: "%-" + "\(subDate)")
  }
}
