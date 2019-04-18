//
//  SettingViewController.swift
//  memo
//
//  Created by MinJun KOO on 05/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import MobileCoreServices
import MaterialComponents.MaterialSnackbar
import Zip


protocol SettingViewControllerDelegate {
  func reloadCollectionViewAndCalendarView(date: String)
  func changeMainViewControllerTheme()
  func changeCalendarMode()
}

class SettingViewController: UIViewController {
  let designList = ["Theme".localized, "Text Size".localized, "Text Thickness".localized, "Vibration".localized, "Prevent Word Truncation".localized, "Calendar Mode".localized, "Notification Permissions Check".localized, "Locking".localized]
  let serviceList = ["Buy Pro Edition".localized, "Backup / Restore".localized, "Leave a Review".localized] //"Contact Us".localized 일시 제거
  let size = ["Small".localized, "Middle".localized, "Big".localized]
  let thickness = ["Thin".localized, "Regular".localized, "Bold".localized]
  let onoff = ["Off".localized, "On".localized]
  let theme = ["White & Blue".localized, "White & Red".localized, "Black & Blue".localized, "Black & Red".localized]
  let lock = ["To Be Updated".localized]
  let calendarMode = ["Week".localized, "Month".localized]

  var delegate: SettingViewControllerDelegate?
  var date: String?
  var isRestoreProgress: Bool = false

  @IBOutlet var appNameLabel: UILabel!
  @IBOutlet var appVersionLabel: UILabel!
  @IBOutlet var closeImageView: UIImageView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var closeButtonView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateSettingViewController()
    if let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
      appVersionLabel.text = "Version \(appVersion)"
    }

    if let theme = SettingManager.shared.theme {
      if theme == .blackRed || theme == .whiteRed {
        appNameLabel.textColor = Color.LightRed
      } else if theme == .blackBlue || theme == .whiteBlue {
        appNameLabel.textColor = Color.Blue
      }
    }

    appNameLabel.text = "Memo:ment"
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

      if indexPath.row == SettingList.CalendarMode.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.CalendarMode) {
          cell.switchLabel.text = calendarMode[value]
          cell.optionTotalCount = calendarMode.count
          cell.currentOption = value
          cell.settingMode = .CalendarMode
          cell.switchLabel.isHidden = false
        }
      }

      if indexPath.row == SettingList.Lock.rawValue {
        if let value = UserDefaults.standard.loadSettings(key: Key.LockFeature) {
          cell.switchLabel.text = lock[value]
          cell.settingTitleLabel.textColor = Color.LightGray
          cell.switchLabel.textColor = Color.LightGray
          cell.optionTotalCount = lock.count
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
    } else if indexPath.section == 1 {
      cell.settingTitleLabel.text = serviceList[indexPath.row]
      cell.switchLabel.isHidden = true
      
      if indexPath.row == ServiceType.BuyProEdition.rawValue {
        cell.serviceType = ServiceType.BuyProEdition
      } else if indexPath.row == ServiceType.BackUp_Restore.rawValue {
        cell.serviceType = ServiceType.BackUp_Restore
      } else if indexPath.row == ServiceType.WriteA_Review.rawValue {
        cell.serviceType = ServiceType.WriteA_Review
      }
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
  func changeCalendarMode() {
    delegate?.changeCalendarMode()
  }
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
    if let theme = SettingManager.shared.theme {
      if theme == .blackRed || theme == .whiteRed {
        appNameLabel.textColor = Color.LightRed
      } else if theme == .blackBlue || theme == .whiteBlue {
        appNameLabel.textColor = Color.Blue
      }
    }
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

  func backupAndRestore() {
    //TODO : 이쪽 부분 번역 완료하기
    let actionViewController = UIAlertController(title: "백업 & 복원", message: "iCloud를 통해서 이용가능합니다.", preferredStyle: .actionSheet)
    let backupAction = UIAlertAction(title: "백업", style: .default) { (action) in
      self.backup()
    }
    let restoreAction = UIAlertAction(title: "복원", style: .default) { (action) in
      self.restore()
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    actionViewController.addAction(backupAction)
    actionViewController.addAction(restoreAction)
    actionViewController.addAction(cancelAction)
    present(actionViewController, animated: true, completion: nil)
  }

  func purchaseAndRestore() {
    let actionViewController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let purchaseAction = UIAlertAction(title: "프로버전 둘러보기", style: .default) { (action) in
      // TODO: show IAP ViewController
    }
    let restoreAction = UIAlertAction(title: "프로버전 복원하기", style: .default) { (action) in
      // TODO: restorePurchaseFunction (purchaseManager를 만들어서 걔가 purchase, restore, check 다 해주자)
      // TODO: 구매를 했는지 확인해서 구매를 했다면, NSUserDefaults에 값을 true로 바꾼 뒤에 그것을 적용해아하는 곳에 세팅하자.
      // TODO: 구매를 하지 않았다면, 구매를 안했을 떄 막아야 할 곳들을 막자 (광고, theme, backup/restore, 장금기능)
    }
    let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
    actionViewController.addAction(purchaseAction)
    actionViewController.addAction(restoreAction)
    actionViewController.addAction(cancelAction)
    present(actionViewController, animated: true, completion: nil)
  }

  private func restoreDatabase(fileName: String, url: URL) {
    let fileManager = FileManager.default
    guard let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.mjkoo.memo") else {
      return
    }

    let fromURL = directory.appendingPathComponent(fileName)
    let toURL = url.appendingPathComponent(fileName)

    if fileManager.fileExists(atPath: fromURL.path) {
      do {
        try fileManager.removeItem(at: fromURL)
      } catch {
        print(error)
      }
      do {
        try fileManager.moveItem(at: toURL, to: fromURL)
      } catch {
        print(error)
      }
    } else {
      do {
        try fileManager.moveItem(at: toURL, to: fromURL)
      } catch {
        print(error)
      }
    }
  }
}


extension SettingViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate,UINavigationControllerDelegate {
  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
    // https://stackoverflow.com/questions/33890225/how-to-access-files-in-icloud-drive-from-within-my-ios-app


    let progressViewController = ProgressViewController()
    progressViewController.modalTransitionStyle = .crossDissolve
    progressViewController.modalPresentationStyle = .overFullScreen
    present(progressViewController, animated: true, completion: nil)

    if isRestoreProgress {
      if url.lastPathComponent == "memoBackup.zip" {
        do {
          let unzipURL = try Zip.quickUnzipFile(url) // Unzip
          restoreDatabase(fileName: "contacts.db", url: unzipURL)
          restoreDatabase(fileName: "completed.db", url: unzipURL)
          if let date = self.date {
            delegate?.reloadCollectionViewAndCalendarView(date: date)
          }
        }
        catch {
          print("Something went wrong")
        }
      } else {
        let message = MDCSnackbarMessage()
        message.text = "You need to select a file named 'memoBackup.zip'".localized
        MDCSnackbarManager().show(message)
      }
    }
    progressViewController.dismiss(animated: true, completion: nil)

  }


  public func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .fullScreen
    documentPicker.modalTransitionStyle = .crossDissolve
    present(documentPicker, animated: true, completion: nil)
  }


  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    let message = MDCSnackbarMessage()
    message.text = "Canceled"
    MDCSnackbarManager().show(message)
  }

  func backup() {
    isRestoreProgress = false
    do {
      let fileManager = FileManager.default
      let directory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.mjkoo.memo")
      let databasePath = directory!.appendingPathComponent("contacts.db")
      let databasePathCompleted = directory!.appendingPathComponent("completed.db")
      let zipFilePath = try Zip.quickZipFiles([databasePath, databasePathCompleted], fileName: "memoBackup") // Zip
      let documentPicker = UIDocumentPickerViewController.init(url: zipFilePath, in: .exportToService)

      documentPicker.delegate = self
      documentPicker.modalPresentationStyle = .formSheet
      self.present(documentPicker, animated: true, completion: nil)
    }
    catch {
      // TODO:  error message
    }
  }

  func restore() {
    isRestoreProgress = true
    let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.archive"], in: .import)
    documentPicker.delegate = self
    documentPicker.modalPresentationStyle = .formSheet
    self.present(documentPicker, animated: true, completion: nil)
  }
}

