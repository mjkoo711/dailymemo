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
    let manager = DateManager()
    let dateList = manager.loadDateList()
    var textList: [Text] = []

    for dateItem in dateList {
      if dateItem.date == date {
        textList = dateItem.textList
        break
      }
    }
    return textList
  }

  private func isExistText(date: String, time: String, text: Text) -> Bool {
    let manager = DateManager()
    let dateList = manager.loadDateList()

    for dateItem in dateList {
      if dateItem.date == date && dateItem.textList.count != 0 {

        for textItem in dateItem.textList {
          if textItem.createdAt == text.createdAt {
            return true
          }
        }
      }
    }
    return false
  }

  private func updateText(date: String, time: String, text: Text) {
    let manager = DateManager()
    let dateList = manager.loadDateList()
    var modifyDate: MDate!

    for dateItem in dateList {
      if dateItem.date == date {
        modifyDate = dateItem
        break
      }
    }

    for index in 0..<modifyDate.textList.count {
      if modifyDate.textList[index].createdAt == text.createdAt {
        modifyDate.textList[index] = text
        break
      }
    }

    manager.recordDate(date: modifyDate)
  }

  private func insertText(date: String, time: String, text: Text) {
    let manager = DateManager()
    let dateList = manager.loadDateList()
    var modifyDate: MDate!

    if manager.isExistDateInstance(dateKey: date) {
      for dateItem in dateList {
        if dateItem.date == date {
          modifyDate = dateItem
          modifyDate.textList.append(text)
          manager.recordDate(date: modifyDate)
          break
        }
      }
    } else {
      modifyDate = MDate(date: date, textList: [text])
      manager.recordDate(date: modifyDate)
    }
  }

  func deleteText(date: String, time: String, text: Text) {
    let manager = DateManager()
    let dateList = manager.loadDateList()
    var modifyDate: MDate!

    if manager.isExistDateInstance(dateKey: date) {
      for dateItem in dateList {
        if dateItem.date == date {
          if dateItem.textList.count == 1 { // 한개가 남았을 땐, 이걸 지우면 그냥 전체가 없어지면 됌.
            manager.deleteDate(date: dateItem)
          } else {
            modifyDate = dateItem
            let textList = modifyDate.textList.filter{ $0.createdAt != text.createdAt }
            modifyDate.textList = textList
            manager.recordDate(date: modifyDate)
          }
        }
      }
    }
  }
}
