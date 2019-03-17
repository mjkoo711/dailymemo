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
  func changeTheme()
}

class SettingViewController: UIViewController {
  let designList = ["테마", "메모 글자 크기", "메모 글자 두께", "진동", "잠금 설정", "알림권한 확인"]
  let serviceList = ["프로버전 구매", "백업 / 복원", "리뷰 남기기", "문의메일 보내기"]
  let size = ["작게", "중간", "크게"]
  let thickness = ["얇게", "보통", "굵게"]
  let onoff = ["끄기", "켜기"]
  let theme = ["화이트 & 블루", "화이트 & 레드", "블랙 & 블루", "블랙 & 레드"]

  var delegate: SettingViewControllerDelegate?
  var date: String?

  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var closeButtonView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    if indexPath.section == 0 {
      cell.settingTitleLabel.text = designList[indexPath.row]
      
      if indexPath.row == SettingList.Theme.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.Theme) {
          cell.switchLabel.text = theme[value]
          cell.optionTotalCount = theme.count
          cell.currentOption = value
          cell.settingMode = .Theme
        }
      } else if indexPath.row == SettingList.FontSize.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.FontSize) {
          cell.switchLabel.text = size[value]
          cell.optionTotalCount = size.count
          cell.currentOption = value
          cell.settingMode = .FontSize
        }
      } else if indexPath.row == SettingList.FontThickness.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.FontWeight) {
          cell.switchLabel.text = thickness[value]
          cell.optionTotalCount = thickness.count
          cell.currentOption = value
          cell.settingMode = .FontThickness
        }
      } else if indexPath.row == SettingList.Vibration.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.Vibrate) {
          cell.switchLabel.text = onoff[value]
          cell.optionTotalCount = onoff.count
          cell.currentOption = value
          cell.settingMode = .Vibration
        }
      } else if indexPath.row == SettingList.Lock.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.LockFeature) {
          cell.switchLabel.text = onoff[value]
          cell.optionTotalCount = onoff.count
          cell.currentOption = value
          cell.settingMode = .Lock
        }
      } else if indexPath.row == SettingList.Alarm.rawValue {
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
  func changeTheme() {
    delegate?.changeTheme()
  }

  func reloadSettings(indexPath: IndexPath) {
    collectionView.reloadItems(at: [indexPath])
  }

  func reloadMainViewController() {
    if let date = date {
      delegate?.reloadCollectionViewAndCalendarView(date: date)
    }
  }
}
