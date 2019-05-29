//
//  DateStringChanger.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DateStringChanger {
  let YearMonthDayCountry = ["ko", "zh", "zh-Hans", "zh-Hant", "zh-HK", "ja", "hu"]
  let MonthDayYearCountry = ["en", "en-GB", "en-AU", "en-CA", "en-IN"]
  fileprivate let formatter = MDateFormatter().formatter
  
  func getStringMonth(month: String) -> String {
    switch month {
    case "01":
      return "January"
    case "02":
      return "Fabruary"
    case "03":
      return "March"
    case "04":
      return "April"
    case "05":
      return "May"
    case "06":
      return "June"
    case "07":
      return "July"
    case "08":
      return "August"
    case "09":
      return "September"
    case "10":
      return "October"
    case "11":
      return "November"
    case "12":
      return "December"
    default:
      return ""
    }
  }

  func getMinimumStringMonth(month: String) -> String {
    switch month {
    case "01":
      return "Jan"
    case "02":
      return "Fab"
    case "03":
      return "Mar"
    case "04":
      return "Apr"
    case "05":
      return "May"
    case "06":
      return "Jun"
    case "07":
      return "Jul"
    case "08":
      return "Aug"
    case "09":
      return "Sep"
    case "10":
      return "Oct"
    case "11":
      return "Nov"
    case "12":
      return "Dec"
    default:
      return ""
    }
  }

  func getStringDayOfWeek(weekDay: Int) -> String {
    switch weekDay {
    case 1:
      return "SUNDAY".localized
    case 2:
      return "MONDAY".localized
    case 3:
      return "TUESDAY".localized
    case 4:
      return "WEDNESDAY".localized
    case 5:
      return "THURSDAY".localized
    case 6:
      return "FRIDAY".localized
    case 7:
      return "SATURDAY".localized
    default:
      return ""
    }
  }

  func getDayOfWeek(_ date: String) -> Int { // yyyy-MM-dd
    let dateChanged = formatter.date(from: date)
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: dateChanged!)
    return weekDay
  }

  func dateFormatChange(dateWithHyphen: String) -> String {
    let array = dateWithHyphen.split(separator: "-")
    let year = array[0]
    let month = getMinimumStringMonth(month: String(array[1]))
    let day = Int(String(array[2]))!

    if let languageCode = Locale.current.languageCode {
      if YearMonthDayCountry.contains(languageCode) {
        return String(format: NSLocalizedString("%@년 %@월 %@일", comment: ""), "\(year)", "\(Int(String(array[1]))!)", "\(day)")
      } else if MonthDayYearCountry.contains(languageCode) {
        return String(format: NSLocalizedString("%@ %@ %@", comment: ""), "\(day)", "\(month)", "\(year)")
      }
    }

    return String(format: NSLocalizedString("%@ %@ %@", comment: ""), "\(day)", "\(month)", "\(year)")
  }
}
