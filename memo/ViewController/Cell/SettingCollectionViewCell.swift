//
//  SettingCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 16/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol SettingCollectionViewCellDelegate {
  func reloadSettings(indexPath: IndexPath)
}

class SettingCollectionViewCell: UICollectionViewCell {
  @IBOutlet var settingTitleLabel: UILabel!
  @IBOutlet var switchLabel: UILabel!

  var indexPath: IndexPath?
  var optionTotalCount: Int?
  var settingMode: SettingList?
  var currentOption: Int?
  
  var delegate: SettingCollectionViewCellDelegate?

  override func awakeFromNib() {
    let tapOptionChangeCell = UITapGestureRecognizer(target: self, action: #selector(tapOptionChange))
    self.addGestureRecognizer(tapOptionChangeCell)
  }

  @objc private func tapOptionChange() {
    Vibration.medium.vibrate()
    if let optionTotalCount = optionTotalCount, let currentOption = currentOption, let settingMode = settingMode {
      let nextOption = currentOption + 1
      let value = nextOption == optionTotalCount ? 0 : nextOption

      if settingMode == .Theme { UserDefaults.standard.saveSettings(value: value, key: Key.DarkTheme) }
      else if settingMode == .FontSize { UserDefaults.standard.saveSettings(value: value, key: Key.FontSize) }
      else if settingMode == .FontThickness { UserDefaults.standard.saveSettings(value: value, key: Key.FontThickness) }
      else if settingMode == .Vibration { UserDefaults.standard.saveSettings(value: value, key: Key.Vibrate) }
      else if settingMode == .Lock { UserDefaults.standard.saveSettings(value: value, key: Key.LockFeature) }
    }

    if let indexPath = indexPath {
      delegate?.reloadSettings(indexPath: indexPath)
    }
  }
}