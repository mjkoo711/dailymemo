//
//  TextManager.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class TextManager {
  func recordText(key: String, text: Text) {
    if isExistText(key: key, text: text) {
      updateText(key: key, text: text)
    } else {
      insertText(key: key, text: text)
    }
  }

  func loadTextList(key: String) -> [Text] {
    let defaults = UserDefaults.standard
    let textList = defaults.decode(for: [Text].self, using: key)
    return textList ?? []
  }

  private func saveTextList(key: String, textList: [Text]) {
    let defaults = UserDefaults.standard
    defaults.encode(for: textList, using: key)
    defaults.synchronize()
  }

  private func isExistText(key: String, text: Text) -> Bool {
    let textLists = loadTextList(key: key)

    for textItem in textLists {
      if textItem.createdAt == text.createdAt {
        return true
      }
    }
    return false
  }

  private func updateText(key: String, text: Text) {
    let textList = loadTextList(key: key)

    for var textItem in textList {
      if textItem.createdAt == text.createdAt {
        textItem.string = text.string
        break;
      }
    }
    saveTextList(key: key, textList: textList)
  }

  private func insertText(key: String, text: Text) {
    var textList: [Text] = []
    let defaults = UserDefaults.standard

    if (defaults.decode(for: [Text].self, using: key) != nil) {
      textList = loadTextList(key: key)
    }

    textList.append(text)
    saveTextList(key: key, textList: textList)
  }

  private func deleteText(key: String, text: Text) {
    let textList = loadTextList(key: key)
    saveTextList(key: key, textList: textList.filter{ $0.createdAt != text.createdAt })
  }
}
