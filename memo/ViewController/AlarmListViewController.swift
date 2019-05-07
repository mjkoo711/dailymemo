//
//  AlarmListViewController.swift
//  memo
//
//  Created by MinJun KOO on 04/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import SCLAlertView
import MaterialComponents.MaterialSnackbar
import UserNotifications


class AlarmListViewController: UIViewController {
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet var messageLabel: UILabel!
  
  var alarmTextList: [Text] = []
  var alarmTextDictionary: [(key: String, value: [Text])] = []
  var textSelected: Text?

  var selectedDatePicked: Date!

  fileprivate let formatter = MDateFormatter().formatter
  fileprivate let formatterLocalized = MDateFormatter().formatterLocalized

  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.prefersLargeTitles = true
    if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      flowLayout.sectionHeadersPinToVisibleBounds = true
    }
    self.navigationItem.title = "Reminder List".localized
    loadSetAlarmText()
    setTheme()
  }

  private func loadSetAlarmText() {
    alarmTextList = TextLoader().findAlarmTextList()

    var dic: [String: [Text]] = [:]

    for text in alarmTextList {
      if let _ = dic["\(formatter.string(from: text.alarmDatePicked!))"] {
        dic["\(formatter.string(from: text.alarmDatePicked!))"]?.append(text)
      } else {
        dic["\(formatter.string(from: text.alarmDatePicked!))"] = [text]
      }
    }
    alarmTextDictionary = dic.sorted { $0.0 < $1.0 }
    if alarmTextList.count == 0 {
      messageLabel.isHidden = false
      messageLabel.text = "No Upcoming Reminder".localized
    } else {
      messageLabel.isHidden = true
    }
  }

  private func setTheme() {
    guard let theme = SettingManager.shared.theme else { return }
    if theme == .blackBlue || theme == .blackRed {
      view.backgroundColor = Color.DarkModeMain
      navigationController?.navigationBar.barTintColor = Color.DarkModeMain
      navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Color.DarkModeFontColor]
      navigationController?.navigationBar.barStyle = .black
      if theme == .blackRed {
        navigationController?.navigationBar.tintColor = Color.LightRed
      } else if theme == .blackBlue {
        navigationController?.navigationBar.tintColor = Color.Blue
      }
    } else if theme == .whiteBlue || theme == .whiteRed {
      view.backgroundColor = Color.WhiteModeMain
      navigationController?.navigationBar.barTintColor = Color.WhiteModeMain
      navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: Color.WhiteModeFontColor]
      navigationController?.navigationBar.barStyle = .default
      if theme == .whiteRed {
        navigationController?.navigationBar.tintColor = Color.LightRed
      } else if theme == .whiteBlue {
        navigationController?.navigationBar.tintColor = Color.Blue
      }
    }
  }
}

extension AlarmListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return alarmTextDictionary[section].value.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCollectionViewCell", for: indexPath) as! AlarmCollectionViewCell

    guard let theme = SettingManager.shared.theme else { return cell }

    cell.textLabel.textColor = Color.White
    cell.dateLabel.textColor = Color.White
    cell.deleteButtonViewImage.image = UIImage(named: "DeleteWhite")

    if theme == .blackBlue || theme == .blackRed {
      cell.backgroundColor = Color.DarkModeSub
      if theme == .blackBlue {
        cell.backgroundColor = Color.Blue
        cell.deleteButtonView.backgroundColor = UIColor.clear
      } else if theme == .blackRed {
        cell.backgroundColor = Color.LightRed
        cell.deleteButtonView.backgroundColor = UIColor.clear
      }
    } else if theme == .whiteBlue || theme == .whiteRed {
      if theme == .whiteBlue {
        cell.backgroundColor = Color.Blue
        cell.deleteButtonView.backgroundColor = UIColor.clear
      } else if theme == .whiteRed {
        cell.backgroundColor = Color.LightRed
        cell.deleteButtonView.backgroundColor = UIColor.clear
      }
    }

    let dateWritten = alarmTextDictionary[indexPath.section].value[indexPath.row].date
    let dateWrittenFormat = DateStringChanger().dateFormatChange(dateWithHyphen: dateWritten)

    cell.textInstance = alarmTextDictionary[indexPath.section].value[indexPath.row]

    cell.textLabel.text = alarmTextDictionary[indexPath.section].value[indexPath.row].string
    cell.dateLabel.text = String(format: NSLocalizedString("Memo Location : %@", comment: ""), dateWrittenFormat)

    cell.delegate = self

    // delete height size 임시방편 코드
    let frame = CGRect(x: cell.deleteButtonView.frame.origin.x, y: cell.deleteButtonView.frame.minY, width: 40, height: cell.frame.height)
    cell.deleteButtonView.frame = frame

    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return alarmTextDictionary.count
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let alarmTimeHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AlarmCollectionReusableView", for: indexPath) as! AlarmCollectionReusableView

    alarmTimeHeaderView.alarmTimeLabel.text = DateStringChanger().dateFormatChange(dateWithHyphen: alarmTextDictionary[indexPath.section].key)

    guard let theme = SettingManager.shared.theme else { return alarmTimeHeaderView }

    if theme == .blackBlue || theme == .blackRed {
      alarmTimeHeaderView.alarmTimeLabel.textColor = Color.DarkModeFontColor
      alarmTimeHeaderView.backgroundColor = Color.DarkModeMain
    } else if theme == .whiteBlue || theme == .whiteRed {
      alarmTimeHeaderView.alarmTimeLabel.textColor = Color.WhiteModeFontColor
      alarmTimeHeaderView.backgroundColor = Color.WhiteModeMain
    }
    return alarmTimeHeaderView
  }
}

extension AlarmListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let constDateTextHeight = "text".height(withConstrainedWidth: UIScreen.main.bounds.width - 40 - 40, font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium))

    let height = alarmTextDictionary[indexPath.section].value[indexPath.row].string.height(withConstrainedWidth: UIScreen.main.bounds.width - 40 - 40, font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)) + constDateTextHeight + 10

    return CGSize(width: UIScreen.main.bounds.width - 20, height: height)
  }
}

extension AlarmListViewController: AlarmCollectionViewCellDelegate {
  func deleteAlarmText(text: Text) {
    text.alarmDatePicked = nil
    text.offAlarmSetting()
    FMDBManager.shared.updateText(text: text)
    AlarmManager().removeNotification(textSelected: text)

    let message = MDCSnackbarMessage()
    message.text = "Reminder was deleted.".localized
    MDCSnackbarManager.show(message)

    self.reloadCollectionView()
  }

  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let textAlarmDate = text.alarmDatePicked, text.isAlarmable() {
      actionSheet.title = text.string
      actionSheet.message = "Reminder Time".localized + "\n" + "\(formatterLocalized.string(from: textAlarmDate))"
    }

    let setAlarmAction = UIAlertAction(title: "Modify Reminder".localized, style: .default, handler: { (action) in
      self.showAlarmSettingView()
    })

    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

    actionSheet.addAction(setAlarmAction)
    actionSheet.addAction(cancelAction)

    present(actionSheet, animated: true, completion: nil)
  }

  private func showAlarmSettingView() {
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 230))
    datePicker.datePickerMode = .dateAndTime
    datePicker.minimumDate = Date()
    datePicker.locale = Locale.init(identifier: Locale.current.languageCode!)
    datePicker.addTarget(self, action:
      #selector(AlarmListViewController.dateSelected(datePicker:)), for: UIControl.Event.valueChanged)
    self.selectedDatePicked = datePicker.date // 이것을 넣은 이유는 selectedDatePicked가 처음에 값이 없기때문

    let appearance = SCLAlertView.SCLAppearance(
      kWindowWidth: datePicker.frame.size.width + 10.0, showCloseButton: false
    )

    let alertView = SCLAlertView(appearance: appearance)
    alertView.customSubview = datePicker
    alertView.addButton("DONE".localized) {
      guard let text = self.textSelected else { return }

      text.alarmDatePicked = self.selectedDatePicked
      FMDBManager.shared.updateText(text: text)
      self.textAlarmTrigger(text: text, isAlarmSetting: true)
      AlarmManager().addNotification(textSelected: text, datePicked: self.selectedDatePicked, notificationType: .Once)
      self.collectionView.reloadData()

      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = Color.LightRed
      message.text = String(format: NSLocalizedString("The reminder time has been changed to %@.", comment: ""), "\(self.formatterLocalized.string(from: datePicker.date))")
      MDCSnackbarManager.show(message)

    }
    alertView.addButton("CANCEL".localized, backgroundColor: Color.LightRed) {

    }
     alertView.showCustom("Modify Reminder".localized, subTitle: "", color: Color.Blue, icon: UIImage(named: "AlarmOnWhite")!)
  }

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDatePicked = datePicker.date
  }

  private func textAlarmTrigger(text: Text, isAlarmSetting: Bool) {
    if isAlarmSetting {
      text.onAlarmSetting()
    } else {
      text.offAlarmSetting()
    }
    FMDBManager.shared.updateText(text: text)
    reloadCollectionView()
  }

  private func reloadCollectionView() {
    loadSetAlarmText()
    collectionView.reloadData()
  }
}


