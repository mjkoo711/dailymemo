//
//  DateManager.swift
//  memo
//
//  Created by MinJun KOO on 04/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DateManager {
  func recordDate(date: MDate) {
    if isExistDate(date: date) {
      updateDate(date: date)
    } else {
      insertDate(date: date)
    }
  }

  func loadDateList() -> [MDate] {
    let defaults = UserDefaults.standard
    let dateList = defaults.decode(for: [MDate].self, using: Const.CalenderKey)
    return dateList ?? []
  }

  private func saveDateList(dateList: [MDate]) {
    let defaults = UserDefaults.standard
    defaults.encode(for: dateList, using: Const.CalenderKey)
    defaults.synchronize()
  }

  private func isExistDate(date: MDate) -> Bool {
    let dateList = loadDateList()

    for dateItem in dateList {
      if dateItem.date == date.date {
        return true
      }
    }
    return false
  }

  private func updateDate(date: MDate) {
    var dateList = loadDateList()

    for index in 0..<dateList.count {
      if dateList[index].date == date.date {
        dateList[index] = date
        break
      }
    }
    saveDateList(dateList: dateList)
  }

  private func insertDate(date: MDate) {
    var dateList: [MDate] = loadDateList()

    dateList.append(date)
    saveDateList(dateList: dateList)
  }

  func deleteDate(date: MDate) {
    let dateList = loadDateList()
    saveDateList(dateList: dateList.filter{ $0.date != date.date })
  }

  func isExistDateInstance(dateKey: String) -> Bool {
    let dateList = loadDateList()

    if dateList.count == 0 {
      return false
    }

    for date in dateList {
      if date.date == dateKey {
        return true
      }
    }
    return false
  }
}
