//
//  TextManager.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class TextManager {
  func recordText(dayKey: String, text: Text) {
    if isExistText(dayKey: dayKey, text: text) {
      updateText(dayKey: dayKey, text: text)
    } else {
      insertText(dayKey: dayKey, text: text)
    }
  }

  func loadTextList(dayKey: String) -> [Text] {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var textList: [Text] = []

    for day in dayList {
      if day.dayKey == dayKey {
        textList = day.textList
        break
      }
    }

    return textList
  }

  private func isExistText(dayKey: String, text: Text) -> Bool {
    let manager = DayManager()
    let dayList = manager.loadDayList()

    for day in dayList {
      if day.dayKey == dayKey && day.textList.count != 0 {

        for textItem in day.textList {
          if textItem.createdAt == text.createdAt {
            return true
          }
        }
      }
    }
    return false
  }

  private func updateText(dayKey: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    for day in dayList {
      if day.dayKey == dayKey {
        modifyDay = day
        break
      }
    }

    for index in 0..<modifyDay.textList.count {
      if modifyDay.textList[index].createdAt == text.createdAt {
        modifyDay.textList[index].string = text.string
        break
      }
    }

    manager.recordDay(day: modifyDay)
  }

  private func insertText(dayKey: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    if manager.isExistDayInstance(dayKey: dayKey) {
      for day in dayList {
        if day.dayKey == dayKey {
          modifyDay = day
          modifyDay.textList.append(text)
          manager.recordDay(day: modifyDay)
          break
        }
      }
    } else {
      modifyDay = Day(date: dayKey, textList: [text])
      manager.recordDay(day: modifyDay)
    }
  }

  private func deleteText(dayKey: String, text: Text) {
    let manager = DayManager()
    let dayList = manager.loadDayList()
    var modifyDay: Day!

    if manager.isExistDayInstance(dayKey: dayKey) {
      for day in dayList {
        if day.dayKey == dayKey {
          modifyDay = day
          let textList = modifyDay.textList.filter{ $0.createdAt != text.createdAt }
          modifyDay.textList = textList
          manager.recordDay(day: modifyDay)
        }
      }
    }
  }
}
