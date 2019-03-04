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

  var setAlarmTextList: [Text] = []
  var alarmSortList: [(key: String, value: [Text])] = []
  var textSelected: Text?

  var selectedDatePicked: Date!

  fileprivate let formatter2: DateFormatter = {
    let formatter2 = DateFormatter()
    formatter2.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter2.amSymbol = "AM"
    formatter2.pmSymbol = "PM"
    formatter2.dateFormat = "YYYY-MM-dd hh:mm a"
    return formatter2
  }()

  fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    loadSetAlarmText()
  }

  private func loadSetAlarmText() {
    let dayList = DayManager().loadDayList()
    var textList: [Text] = []
    var dic: [String: [Text]] = [:]

    for day in dayList {
      textList += day.textList
    }

    for text in textList {
      if text.isAlarmSetting {
        setAlarmTextList.append(text)
        if let _ = dic["\(formatter.string(from: text.alarmDatePicked!))"] {
          dic["\(formatter.string(from: text.alarmDatePicked!))"]?.append(text)
        } else {
          dic["\(formatter.string(from: text.alarmDatePicked!))"] = [text]
        }
      }
    }
    alarmSortList = dic.sorted { $0.0 < $1.0 }
  }
}

extension AlarmListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return alarmSortList[section].value.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCollectionViewCell", for: indexPath) as! AlarmCollectionViewCell
    cell.textInstance = alarmSortList[indexPath.section].value[indexPath.row]

    cell.textLabel.text = alarmSortList[indexPath.section].value[indexPath.row].string
    cell.dateLabel.text = alarmSortList[indexPath.section].value[indexPath.row].date + "에 작성"

    cell.delegate = self
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return alarmSortList.count
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let alarmTimeHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AlarmCollectionReusableView", for: indexPath) as! AlarmCollectionReusableView

    alarmTimeHeaderView.alarmTimeLabel.text = alarmSortList[indexPath.section].key
    return alarmTimeHeaderView
  }
}

extension AlarmListViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let constDateTextHeight = "text".height(withConstrainedWidth: UIScreen.main.bounds.width, font: UIFont(name: "Helvetica Neue", size: 17)!)

    let height = alarmSortList[indexPath.section].value[indexPath.row].string.height(withConstrainedWidth: UIScreen.main.bounds.width, font: UIFont(name: "Helvetica Neue", size: 17)!) + 10 + constDateTextHeight
    return CGSize(width: UIScreen.main.bounds.width, height: height)
  }
}

extension AlarmListViewController: AlarmCollectionViewCellDelegate {
  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let textAlarmDate = text.alarmDatePicked, text.isAlarmSetting {
      actionSheet.title = "알람 예정시간"
      actionSheet.message = "\(formatter2.string(from: textAlarmDate))"
    }

    let setAlarmAction = UIAlertAction(title: "Modify Alarm", style: .default, handler: { (action) in
      self.showAlarmSettingView()
    })

    let deleteAlarm = UIAlertAction(title: "Remove Alarm", style: .destructive, handler: { (action) in
      if let text = self.textSelected {
        text.offAlarmSetting()
        TextManager().recordText(date: text.date, time: text.time, text: text)
        AlarmManager().removeNotification(textSelected: text)
        self.reloadCollectionView()
      }
    })

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    actionSheet.addAction(setAlarmAction)
    actionSheet.addAction(deleteAlarm)
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
      TextManager().recordText(date: text.date, time: text.time, text: text)
      self.textAlarmTrigger(text: text, isAlarmSetting: true)
      AlarmManager().addNotification(textSelected: text, datePicked: self.selectedDatePicked, notificationType: .Once)
      self.collectionView.reloadData()

      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = UIColor.red
      message.text = "알람시간이 \(self.formatter2.string(from: datePicker.date))로 변경되었습니다."

      MDCSnackbarManager.show(message)

    }
    alertView.addButton("CANCEL", backgroundColor: UIColor.red) {

    }
    alertView.showTitle("알림설정", subTitle: "해당 키워드에 대해 알람을 설정하신 적이 있다면 지금 설정하는 것으로 최신화됩니다.", style: .notice)
  }

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDatePicked = datePicker.date
  }

  private func textAlarmTrigger(text: Text, isAlarmSetting: Bool) {
    let textManager = TextManager()
    if isAlarmSetting {
      text.onAlarmSetting()
    } else {
      text.offAlarmSetting()
    }
    textManager.recordText(date: text.date, time: text.time, text: text)
    reloadCollectionView()
  }

  private func reloadCollectionView() {
    loadSetAlarmText()
    collectionView.reloadData()
  }
}


