//
//  Vibrate.swift
//  memo
//
//  Created by MinJun KOO on 20/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

enum Vibrate: Int {
  case off = 0, on

  func onoff() -> Int {
    switch self {
    case .off:
      return 0
    case .on:
      return 1
    }
  }
}
