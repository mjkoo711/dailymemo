//
//  FontSize.swift
//  memo
//
//  Created by MinJun KOO on 16/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

enum FontSize: Int {
  case small = 0, middle, large

  func size() -> CGFloat {
    switch self {
    case .small:
      return 14.0
    case .middle:
      return 16.0
    case .large:
      return 18.0
    }
  }
}
