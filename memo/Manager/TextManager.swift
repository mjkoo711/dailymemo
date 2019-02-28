//
//  TextManager.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class TextManager {
  func recordText(date: String, time: String, text: Text) {
    if isExistText(date: date, time: time, text: text) {
      updateText(date: date, time: time, text: text)
    } else {
      insertText(date: date, time: time, text: text)
    }
  }

  func loadTextList(date: String) -> [Text] {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var textList: [Text] = []

    for day in dayList {
      if day.date == date {
        textList = day.textList
        break
      }
    }
    return textList
  }

  private func isExistText(date: String, time: String, text: Text) -> Bool {
    let manager = DayManager()
    let dayList = manager.loadDayList()

    for day in dayList {
      if day.date == date && day.textList.count != 0 {

        for textItem in day.textList {
          if textItem.createdAt == text.createdAt {
            return true
          }
        }
      }
    }
    return false
  }

  private func updateText(date: String, time: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    for day in dayList {
      if day.date == date {
        modifyDay = day
        break
      }
    }

    for index in 0..<modifyDay.textList.count {
      if modifyDay.textList[index].createdAt == text.createdAt {
        modifyDay.textList[index] = text
        break
      }
    }

    manager.recordDay(day: modifyDay)
  }

  private func insertText(date: String, time: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    if manager.isExistDayInstance(dayKey: date) {
      for day in dayList {
        if day.date == date {
          modifyDay = day
          modifyDay.textList.append(text)
          manager.recordDay(day: modifyDay)
          break
        }
      }
    } else {
      modifyDay = Day(date: date, textList: [text])
      manager.recordDay(day: modifyDay)
    }
  }

  func deleteText(date: String, time: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    if manager.isExistDayInstance(dayKey: date) {
      for day in dayList {
        if day.date == date {
          if day.textList.count == 1 { // 한개가 남았을 땐, 이걸 지우면 그냥 전체가 없어지면 됌.
            manager.deleteDay(day: day)
          } else {
            modifyDay = day
            let textList = modifyDay.textList.filter{ $0.createdAt != text.createdAt }
            modifyDay.textList = textList
            manager.recordDay(day: modifyDay)
          }
        }
      }
    }
  }
}
