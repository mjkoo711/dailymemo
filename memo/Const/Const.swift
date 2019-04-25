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

  static let AppID = "1457446485"
  static let RequestAppReviewRateCount = 10
  
  static let DAY = TimeInterval(60.0 * 60.0 * 24.0)
//
  static let admobAppId = Bundle.main.infoDictionary!["GADApplicationIdentifier"] as! String
  static let adUnitId = "ca-app-pub-6738092375038703/7447636953"
}

