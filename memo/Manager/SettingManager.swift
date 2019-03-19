//
//  SettingManager.swift
//  memo
//
//  Created by MinJun KOO on 16/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

class SettingManager {
  static let shared = SettingManager()
  var fontSize: CGFloat?
  var fontWeight: UIFont.Weight?
  var vibrate: Vibrate?
  var theme: Theme?
  var lineBreak: LineBreak?

  private init() { }

  func setFontSize(value: Int) {
    if value == FontSize.small.rawValue {
      fontSize = FontSize.small.size()
    } else if value == FontSize.middle.rawValue {
      fontSize = FontSize.middle.size()
    } else if value == FontSize.large.rawValue {
      fontSize = FontSize.large.size()
    }
  }

  func setFontWeight(value: Int) {
    if value == FontWeight.light.rawValue {
      fontWeight = FontWeight.light.size()
    } else if value == FontWeight.regular.rawValue {
      fontWeight = FontWeight.regular.size()
    } else if value == FontWeight.medium.rawValue {
      fontWeight = FontWeight.medium.size()
    }
  }

  func setVibration(value: Int) {
    if value == 0 {
      vibrate = Vibrate.off
    } else {
      vibrate = Vibrate.on
    }
  }

  func setTheme(value: Int) {
    if value == Theme.whiteBlue.rawValue {
      theme = Theme.whiteBlue
    } else if value == Theme.whiteRed.rawValue {
      theme = Theme.whiteRed
    } else if value == Theme.blackBlue.rawValue {
      theme = Theme.blackBlue
    } else if value == Theme.blackRed.rawValue {
      theme = Theme.blackRed
    }
  }

  func setLineBreak(value: Int) {
    if value == 0 {
      lineBreak = LineBreak.off
    } else {
      lineBreak = LineBreak.on
    }
  }
}
