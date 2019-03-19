//
//  SettingViewController.swift
//  memo
//
//  Created by MinJun KOO on 05/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol SettingViewControllerDelegate {
  func reloadCollectionViewAndCalendarView(date: String)
  func changeMainViewControllerTheme()
}

class SettingViewController: UIViewController {
  let designList = ["테마", "메모 글자 크기", "메모 글자 두께", "진동", "잠금 설정", "단어잘림 방지", "알림권한 확인"]
  let serviceList = ["프로버전 구매", "백업 / 복원", "리뷰 남기기", "문의메일 보내기"]
  let size = ["작게", "중간", "크게"]
  let thickness = ["얇게", "보통", "굵게"]
  let onoff = ["끄기", "켜기"]
  let theme = ["화이트 & 블루", "화이트 & 레드", "블랙 & 블루", "블랙 & 레드"]

  var delegate: SettingViewControllerDelegate?
  var date: String?

  @IBOutlet var closeImageView: UIImageView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var closeButtonView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateSettingViewController()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    closeButtonView.addGestureRecognizer(tapGesture)
  }
}

extension SettingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return designList.count
    } else {
      return serviceList.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCollectionViewCell", for: indexPath) as! SettingCollectionViewCell
    guard let themeValue = SettingManager.shared.theme else { return cell }

    if themeValue == .blackBlue || themeValue == .blackRed {
      cell.settingTitleLabel.textColor = Color.DarkModeFontColor
      cell.switchLabel.textColor = Color.DarkModeFontColor
      cell.imageView.image = UIImage(named: "ArrowWhite")
    } else if themeValue == .whiteRed || themeValue == .whiteBlue {
      cell.settingTitleLabel.textColor = Color.WhiteModeFontColor
      cell.switchLabel.textColor = Color.WhiteModeFontColor
      cell.imageView.image = UIImage(named: "Arrow")
    }

    if indexPath.section == 0 {
      cell.settingTitleLabel.text = designList[indexPath.row]
      if indexPath.row == SettingList.Theme.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.Theme) {
          cell.switchLabel.text = theme[value]
          cell.optionTotalCount = theme.count
          cell.currentOption = value
          cell.settingMode = .Theme

          if themeValue == .whiteRed || themeValue == .blackRed {
            cell.switchLabel.textColor = Color.LightRed
          } else if themeValue == .blackBlue || themeValue == .whiteBlue {
            cell.switchLabel.textColor = Color.Blue
          }
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.FontSize.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.FontSize) {
          cell.switchLabel.text = size[value]
          cell.optionTotalCount = size.count
          cell.currentOption = value
          cell.settingMode = .FontSize
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.FontThickness.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.FontWeight) {
          cell.switchLabel.text = thickness[value]
          cell.optionTotalCount = thickness.count
          cell.currentOption = value
          cell.settingMode = .FontThickness
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.Vibration.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.Vibrate) {
          cell.switchLabel.text = onoff[value]
          cell.optionTotalCount = onoff.count
          cell.currentOption = value
          cell.settingMode = .Vibration
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.Lock.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.LockFeature) {
          cell.switchLabel.text = onoff[value]
          cell.optionTotalCount = onoff.count
          cell.currentOption = value
          cell.settingMode = .Lock
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.LineBreak.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.LineBreak) {
          cell.switchLabel.text = onoff[value]
          cell.optionTotalCount = onoff.count
          cell.currentOption = value
          cell.settingMode = .LineBreak
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.Alarm.rawValue {
        cell.switchLabel.isHidden = true
        cell.optionTotalCount = 0
        cell.currentOption = 0
        cell.settingMode = .Alarm
      }
    } else {
      cell.settingTitleLabel.text = serviceList[indexPath.row]
      cell.switchLabel.isHidden = true
    }

    cell.delegate = self
    cell.indexPath = indexPath
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: 35.0)
  }
}

extension SettingViewController {
  @objc func returnMainViewController() {
    Vibration.heavy.vibrate()
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}

extension SettingViewController: SettingCollectionViewCellDelegate {
  func updateSettingViewController() {
    guard let value = SettingManager.shared.theme else { return }
    if value == .blackBlue || value == .blackRed {
      self.view.backgroundColor = Color.DarkModeMain
      self.closeImageView.image = UIImage(named: "CloseWhite")
    } else if value == .whiteRed || value == .whiteBlue {
      self.view.backgroundColor = Color.WhiteModeMain
      self.closeImageView.image = UIImage(named: "Close")
    }
  }

  func changeTheme() {
    delegate?.changeMainViewControllerTheme()
  }

  func reloadSettings(indexPath: IndexPath) {
    updateSettingViewController()
    collectionView.reloadData()
  }

  func reloadMainViewController() {
    if let date = date {
      delegate?.reloadCollectionViewAndCalendarView(date: date)
    }
  }
}
