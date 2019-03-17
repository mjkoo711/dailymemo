//
//  FontWeight.swift
//  memo
//
//  Created by MinJun KOO on 17/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

enum FontWeight: Int {
  case light = 0, regular, medium

  func size() -> UIFont.Weight {
    switch self {
    case .light:
      return UIFont.Weight.light
    case .regular:
      return UIFont.Weight.regular
    case .medium:
      return UIFont.Weight.medium
    }
  }
}
