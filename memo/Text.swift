//
//  Text.swift
//  memo
//
//  Created by MinJun KOO on 30/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

struct Text: Codable {
  var string: String
  var date: String
  var time: String
  var createdAt: String!

  init(string: String, date: String, time: String) {
    self.string = string
    self.date = date
    self.time = time
    self.createdAt = date + " " + time
  }
}
