//
//  DayManager.swift
//  memo
//
//  Created by MinJun KOO on 04/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DayManager {
  func recordDay(day: Day) {
    if isExistDay(day: day) {
      updateDay(day: day)
    } else {
      insertDay(day: day)
    }
  }

  func loadDayList() -> [Day] {
    let defaults = UserDefaults.standard
    let dayList = defaults.decode(for: [Day].self, using: Const.CalenderKey)
    return dayList ?? []
  }

  private func saveDayList(dayList: [Day]) {
    let defaults = UserDefaults.standard
    defaults.encode(for: dayList, using: Const.CalenderKey)
    defaults.synchronize()
  }

  private func isExistDay(day: Day) -> Bool {
    let dayList = loadDayList()

    for dayItem in dayList {
      if dayItem.dayKey == day.dayKey {
        return true
      }
    }
    return false
  }

  private func updateDay(day: Day) {
    var dayList = loadDayList()

    for index in 0..<dayList.count {
      if dayList[index].dayKey == day.dayKey {
        dayList[index] = day
        break
      }
    }
    saveDayList(dayList: dayList)
  }

  private func insertDay(day: Day) {
    var dayList: [Day] = loadDayList()

    dayList.append(day)
    saveDayList(dayList: dayList)
  }

  private func deleteDay(day: Day) {
    let dayList = loadDayList()
    saveDayList(dayList: dayList.filter{ $0.dayKey != day.dayKey })
  }

  func isExistDayInstance(dayKey: String) -> Bool {
    let dayList = loadDayList()

    if dayList.count == 0 {
      return false
    }

    for day in dayList {
      if day.dayKey == dayKey {
        return true
      }
    }
    return false
  }
}
