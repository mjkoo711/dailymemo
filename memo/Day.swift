//
//  Day.swift
//  memo
//
//  Created by MinJun KOO on 04/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class Day: Codable {
  var dayKey: String
  var textList: [Text]

  init(date: String, textList: [Text]) {
    dayKey = date
    self.textList = textList
  }
}
