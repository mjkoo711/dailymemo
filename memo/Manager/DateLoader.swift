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
}
