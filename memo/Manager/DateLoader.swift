//
//  DateLoader.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DateLoader {
  func findAlarmDateList() -> [String] {
    let querySQL = "SELECT date FROM CONTACTS WHERE repeatmode = 0 and is_alarm_setting = 1 GROUP BY date ORDER BY date"
    return FMDBManager.shared.selectDateList(sql: querySQL)
  }

  func findOnceDateList() -> [String] {
    let querySQL = "SELECT date FROM CONTACTS WHERE repeatmode = 0 GROUP BY date ORDER BY date"
    return FMDBManager.shared.selectDateList(sql: querySQL)
  }

  func findWeeklyDateList(date: String) -> [String] {
    let querySQL = "SELECT date FROM CONTACTS WHERE repeatmode = 2 and date = \(date) GROUP BY date ORDER BY date"
    return FMDBManager.shared.selectDateList(sql: querySQL)
  }

  func findMonthlyDateList(date: String) -> [String] {
    let querySQL = "SELECT date FROM CONTACTS WHERE repeatmode = 3 and date = \(date) GROUP BY date ORDER BY date"
    return FMDBManager.shared.selectDateList(sql: querySQL)
  }
}
