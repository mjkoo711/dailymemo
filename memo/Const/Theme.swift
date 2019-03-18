//
//  Theme.swift
//  memo
//
//  Created by MinJun KOO on 17/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

enum Theme: Int {
  case whiteBlue = 0, whiteRed, blackBlue, blackRed

  func size() -> Int {
    switch self {
    case .whiteBlue:
      return Theme.whiteBlue.rawValue
    case .whiteRed:
      return Theme.whiteRed.rawValue
    case .blackBlue:
      return Theme.blackBlue.rawValue
    case .blackRed:
      return Theme.blackRed.rawValue
    }
  }
}
