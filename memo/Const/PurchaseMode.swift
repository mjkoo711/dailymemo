//
//  PurchaseMode.swift
//  memo
//
//  Created by MinJun KOO on 23/04/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

enum PurchaseMode: Int {
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
