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

  var alarmTextList: [Text] = []
  var alarmTextDictionary: [(key: String, value: [Text])] = []
  var textSelected: Text?

  var selectedDatePicked: Date!

  fileprivate let formatter2 = MDateFormatter().formatter2
  fileprivate let formatter = MDateFormatter().formatter

  override func viewDidLoad() {
    super.viewDidLoad()
    loadSetAlarmText()
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
  }
}

extension AlarmListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return alarmTextDictionary[section].value.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCollectionViewCell", for: indexPath) as! AlarmCollectionViewCell
    cell.textInstance = alarmTextDictionary[indexPath.section].value[indexPath.row]

    cell.textLabel.text = alarmTextDictionary[indexPath.section].value[indexPath.row].string
    cell.dateLabel.text = "작성 일자: " + alarmTextDictionary[indexPath.section].value[indexPath.row].date

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
    text.offAlarmSetting()
    FMDBManager.shared.updateText(text: text)
    AlarmManager().removeNotification(textSelected: text)
    self.reloadCollectionView()
  }

  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let textAlarmDate = text.alarmDatePicked, text.isAlarmable() {
      actionSheet.title = text.string
      actionSheet.message = "알람 예정시간\n" + "\(formatter2.string(from: textAlarmDate))"
    }

    let setAlarmAction = UIAlertAction(title: "Modify Alarm", style: .default, handler: { (action) in
      self.showAlarmSettingView()
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

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
    alertView.addButton("DONE") {
      guard let text = self.textSelected else { return }

      text.alarmDatePicked = self.selectedDatePicked
      FMDBManager.shared.updateText(text: text)
      self.textAlarmTrigger(text: text, isAlarmSetting: true)
      AlarmManager().addNotification(textSelected: text, datePicked: self.selectedDatePicked, notificationType: .Once)
      self.collectionView.reloadData()

      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = Color.LightRed
      message.text = "알람시간이 \(self.formatter2.string(from: datePicker.date))로 변경되었습니다."

      MDCSnackbarManager.show(message)

    }
    alertView.addButton("CANCEL", backgroundColor: Color.LightRed) {

    }
    alertView.showTitle("알림설정", subTitle: "해당 키워드에 대해 알람을 설정하신 적이 있다면 지금 설정하는 것으로 최신화됩니다.", style: .notice)
  }

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDatePicked = datePicker.date
  }

  private func textAlarmTrigger(text: Text, isAlarmSetting: Bool) {
//    let textManager = OnceTextManager()
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


