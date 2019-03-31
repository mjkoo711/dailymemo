//
//  CalendarMode.swift
//  memo
//
//  Created by MinJun KOO on 31/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

enum CalendarMode: Int {
  case week = 0, month

  func toggle() -> Int {
    switch self {
    case .week:
      return 0
    case .month:
      return 1
    }
  }
}
