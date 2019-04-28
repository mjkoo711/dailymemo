//
//  SettingCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 16/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar
import UserNotifications
import StoreKit

protocol SettingCollectionViewCellDelegate {
  func reloadSettings(indexPath: IndexPath)
  func reloadMainViewController()
  func changeTheme()
  func updateSettingViewController()
  func backupAndRestore()
  func purchaseAndRestore()
  func changeCalendarMode()
  func showStartKit()
}

class SettingCollectionViewCell: UICollectionViewCell {
  @IBOutlet var settingTitleLabel: UILabel!
  @IBOutlet var switchLabel: UILabel!
  @IBOutlet var imageView: UIImageView!

  var indexPath: IndexPath?
  var optionTotalCount: Int?
  var settingMode: SettingList?
  var serviceType: ServiceType?
  var currentOption: Int?
  
  var delegate: SettingCollectionViewCellDelegate?

  override func awakeFromNib() {
    let tapOptionChangeCell = UITapGestureRecognizer(target: self, action: #selector(tapOptionChange))
    self.addGestureRecognizer(tapOptionChangeCell)
  }

  @objc private func tapOptionChange() {
    Vibration.heavy.vibrate()
    guard let indexPath = indexPath else { return }
    if indexPath.section == 0 {
      if let optionTotalCount = optionTotalCount, let currentOption = currentOption, let settingMode = settingMode {
        let nextOption = currentOption + 1
        let value = nextOption == optionTotalCount ? 0 : nextOption

        if settingMode == .Theme {
          if let purchaseMode = SettingManager.shared.purchaseMode, purchaseMode == .off {
            self.showSnackbar()
            return
          }
          UserDefaults.standard.saveSettings(value: value, key: Key.Theme)
          SettingManager.shared.setTheme(value: value)
          delegate?.changeTheme()
        }
        else if settingMode == .FontSize {
          UserDefaults.standard.saveSettings(value: value, key: Key.FontSize)
          SettingManager.shared.setFontSize(value: value)
        }
        else if settingMode == .FontThickness {
          UserDefaults.standard.saveSettings(value: value, key: Key.FontWeight)
          SettingManager.shared.setFontWeight(value: value)
        }
        else if settingMode == .Vibration {
          UserDefaults.standard.saveSettings(value: value, key: Key.Vibrate)
          SettingManager.shared.setVibration(value: value)
        }
        else if settingMode == .Lock {
          UserDefaults.standard.saveSettings(value: value, key: Key.LockFeature)
          // TODO
        }
        else if settingMode == .LineBreak {
          UserDefaults.standard.saveSettings(value: value, key: Key.LineBreak)
          SettingManager.shared.setLineBreak(value: value)
        }
        else if settingMode == .CalendarMode {
          UserDefaults.standard.saveSettings(value: value, key: Key.CalendarMode)
          SettingManager.shared.setCalendarMode(value: value)
          delegate?.changeCalendarMode()
        }
        else if settingMode == .Alarm {
          let current = UNUserNotificationCenter.current()

          current.getNotificationSettings(completionHandler: { settings in

            switch settings.authorizationStatus {
            case .denied, .notDetermined:
              DispatchQueue.main.async {
                let message = MDCSnackbarMessage()
                message.text = "Notification permission had not allowed.".localized
                if let theme = SettingManager.shared.theme {
                  if theme == .blackRed || theme == .whiteRed {
                    message.buttonTextColor = Color.LightRed
                  } else if theme == .blackBlue || theme == .whiteBlue {
                    message.buttonTextColor = Color.Blue
                  }
                }

                let action = MDCSnackbarMessageAction()
                let actionHandler = {() in
                  guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                  }
                  if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                      print("Settings opened: \(success)") // Prints true
                    })
                  }
                }
                action.handler = actionHandler
                action.title = "Set Up".localized

                message.action = action
                MDCSnackbarManager.show(message)
              }
            case .authorized:
              DispatchQueue.main.async {
                let message = MDCSnackbarMessage()
                message.text = "Notification Permission has already been allowed".localized
                MDCSnackbarManager.show(message)
              }
            case .provisional:
              DispatchQueue.main.async {
                let message = MDCSnackbarMessage()
                message.text = "Provisional".localized
                MDCSnackbarManager.show(message)
              }
            }
          })
        }
      }
    } else if indexPath.section == 1 {
      if let serviceType = serviceType {
        if serviceType == .BuyProEdition {
          if let purchaseMode = SettingManager.shared.purchaseMode, purchaseMode == .on {
            let message = MDCSnackbarMessage()
            message.text = "You already purchase Memoment Pro.".localized
            if let theme = SettingManager.shared.theme {
              if theme == .blackRed || theme == .whiteRed {
                message.buttonTextColor = Color.LightRed
              } else if theme == .blackBlue || theme == .whiteBlue {
                message.buttonTextColor = Color.Blue
              }
            }

            MDCSnackbarManager.show(message)
            return
          }
          delegate?.purchaseAndRestore()
        } else if serviceType == .BackUp_Restore {
          if let purchaseMode = SettingManager.shared.purchaseMode, purchaseMode == .off {
            self.showSnackbar()
            return
          }
          delegate?.backupAndRestore()
        } else if serviceType == .WriteA_Review {
          self.showAppStoreReviewPage()
        } else if serviceType == .Rate {
          SKStoreReviewController.requestReview()
        } else if serviceType == .StartKit {
          delegate?.showStartKit()
        }
      }
    }

    if indexPath.section == 0, indexPath.row != SettingList.Alarm.rawValue {
      delegate?.reloadSettings(indexPath: indexPath)
      delegate?.reloadMainViewController()
    }
  }

  private func showSnackbar() {
    let message = MDCSnackbarMessage()
    message.text = "Pro version is available for purchase.".localized
    if let theme = SettingManager.shared.theme {
      if theme == .blackRed || theme == .whiteRed {
        message.buttonTextColor = Color.LightRed
      } else if theme == .blackBlue || theme == .whiteBlue {
        message.buttonTextColor = Color.Blue
      }
    }

    let action = MDCSnackbarMessageAction()
    let actionHandler = {() in
      if let delegate = self.delegate {
        delegate.purchaseAndRestore()
      }
    }
    action.handler = actionHandler
    action.title = "Purchase".localized

    message.action = action
    MDCSnackbarManager.show(message)
  }

  private func showAppStoreReviewPage() {
    let alertViewController = UIAlertController(title: "Thank You".localized, message: "The developer will be happy if you write down your app's wishes or compliments.".localized + " 🥰😍", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .destructive, handler: nil)
    let goAction = UIAlertAction(title: "Leave Comment".localized, style: .default) { (action) in
      guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id\(Const.AppID)?action=write-review")
        else { fatalError("Expected a valid URL") }
      UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    alertViewController.addAction(cancelAction)
    alertViewController.addAction(goAction)
    self.parentContainerViewController()?.present(alertViewController, animated: true, completion: nil)
  }
}
