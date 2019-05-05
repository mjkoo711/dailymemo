//
//  MDateFormatter.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

struct MDateFormatter {
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  let formatter2: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.dateFormat = "YYYY-MM-dd hh:mm a"
    return formatter
  }()

  let formatterLocalized: DateFormatter = {
    var localDateFormat = ""
    let YearMonthDayCountry = ["ko", "zh", "zh-Hans", "zh-Hant", "zh-HK", "ja", "hu"]
    let MonthDayYearCountry = ["en", "en-GB", "en-AU", "en-CA", "en-IN"]

    if let languageCode = Locale.current.languageCode {
      if YearMonthDayCountry.contains(languageCode) {
        localDateFormat = String(format: NSLocalizedString("%@년 %@월 %@일", comment: ""), "YYYY", "MM", "dd")
      } else if MonthDayYearCountry.contains(languageCode) {
        localDateFormat = String(format: NSLocalizedString("%@ %@ / %@", comment: ""), "dd", "MM", "YYYY")
      } else {
        localDateFormat = String(format: NSLocalizedString("%@ %@ / %@", comment: ""), "dd", "MM", "YYYY")
      }
    }

    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.dateFormat = localDateFormat + " " + "hh:mm a"
    return formatter
  }()

  let formatterKorea: DateFormatter = {
    let formatterKorea = DateFormatter()
    formatterKorea.dateFormat = "YYYY년 MM월 dd일"
    return formatterKorea
  }()
}
