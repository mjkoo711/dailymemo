//
//  Day.swift
//  memo
//
//  Created by MinJun KOO on 04/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

class Day: Codable {
  var date: String
  var textList: [Text]

  init(date: String, textList: [Text]) {
    self.date = date
    self.textList = textList
  }
}
