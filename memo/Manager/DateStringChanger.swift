//
//  DateStringChanger.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DateStringChanger {
  fileprivate let formatter = MDateFormatter().formatter
  
  func getStringYear(year: String) -> String {
    switch year {
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

  func getStringDayOfWeek(weekDay: Int) -> String {
    switch weekDay {
    case 1:
      return "Sunday"
    case 2:
      return "Monday"
    case 3:
      return "Tuesday"
    case 4:
      return "Wednesday"
    case 5:
      return "Thursday"
    case 6:
      return "Friday"
    case 7:
      return "Saturday"
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

    return "\(array[0])년 \(array[1])월 \(array[2])일"
  }
}
