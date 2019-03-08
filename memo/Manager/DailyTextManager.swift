//
//  DailyTextManager.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class DailyTextManager {
  func recordText(text: Text) {
    if isExistText(text: text) {
      updateText(text: text)
    } else {
      insertText(text: text)
    }
  }

  func loadTextList() -> [Text] {
    let defaults = UserDefaults.standard
    let textList = defaults.decode(for: [Text].self, using: Const.DailyTextKey) ?? []
    return textList
  }

  private func saveTextList(textList: [Text]) {
    let defaults = UserDefaults.standard
    defaults.encode(for: textList, using: Const.DailyTextKey)
    defaults.synchronize()
  }

  private func isExistText(text: Text) -> Bool {
    let textList = loadTextList()
    for textItem in textList {
      if textItem.createdAt == text.createdAt {
        return true
      }
    }
    return false
  }

  private func updateText(text: Text) {
    var textList = loadTextList()

    for index in 0..<textList.count {
      if textList[index].createdAt == text.createdAt {
        textList[index] = text
        break
      }
    }
    saveTextList(textList: textList)
  }

  private func insertText(text: Text) {
    var textList: [Text] = loadTextList()
    textList.append(text)
    saveTextList(textList: textList)
  }

  func deleteText(text: Text) {
    let textList = loadTextList()
    saveTextList(textList: textList.filter{ $0.createdAt != text.createdAt })
  }
}
