//
//  Const.swift
//  memo
//
//  Created by MinJun KOO on 04/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

enum Const {
  static let CalenderKey = "KCalendar"
  static let DailyTextKey = "KDailyTextKey"
  static let WeeklyTextKey = "KWeeklyTextKey"
  static let MonthlyTextKey = "KMonthlyTextKey"
  
  static let DAY = TimeInterval(60.0 * 60.0 * 24.0)

  #if DEBUG
  static let appId = Bundle.main.infoDictionary!["GADApplicationIdentifierTest"] as! String
  #else
  static let appId = Bundle.main.infoDictionary!["GADApplicationIdentifier"] as! String
  #endif
}

