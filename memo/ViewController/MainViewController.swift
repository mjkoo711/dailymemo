//
//  MainViewController.swift
//  memo
//
//  Created by MinJun KOO on 25/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import FSCalendar
import SCLAlertView
import MaterialComponents.MaterialSnackbar
import UserNotifications

class MainViewController: UIViewController {
  @IBOutlet var calendarView: FSCalendar!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var dayLabel: UILabel!

  @IBOutlet var showAlarmListButtonView: UIView!
  @IBOutlet var showSettingButtonView: UIView!
  @IBOutlet var todayLabel: UILabel!

  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet weak var timeLabel: UILabel!

  @IBOutlet var previousMonthButtonView: UIView!
  @IBOutlet var nextMonthButtonView: UIView!
  @IBOutlet var previousDayButtonView: UIView!
  @IBOutlet var nextDayButtonView: UIView!


  fileprivate let gregorian = Calendar(identifier: .gregorian)
  fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  fileprivate let formatter2: DateFormatter = {
    let formatter2 = DateFormatter()
    formatter2.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter2.amSymbol = "AM"
    formatter2.pmSymbol = "PM"
    formatter2.dateFormat = "YYYY-MM-dd hh:mm a"
    return formatter2
  }()

  let clock = Clock()
  var timeChanger: Timer?

  var textSelected: Text?

  var textList: [Text] = []
  var dateList: [MDate] = []

  var selectedDatePicked: Date!

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.placeholderType = .none
    dateLabel.text = formatter.string(from: Date())
    dayLabel.text = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(formatter.string(from: Date())))

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.updateTimeLabel), userInfo: nil, repeats: true)

    let tapGestureForCollectionView = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGestureForCollectionView)

    let tapGestureForAlarmListButtonView = UITapGestureRecognizer(target: self, action: #selector(showAlarmList))
    showAlarmListButtonView.addGestureRecognizer(tapGestureForAlarmListButtonView)

    let tapGestureForSettingButtonView = UITapGestureRecognizer(target: self, action: #selector(showSettingViewController))
    showSettingButtonView.addGestureRecognizer(tapGestureForSettingButtonView)

    let tapGestureForPreviousMonthButtonView = UITapGestureRecognizer(target: self, action: #selector(movePreviousMonth))
    previousMonthButtonView.addGestureRecognizer(tapGestureForPreviousMonthButtonView)

    let tapGestureForPreviousDayButtonView = UITapGestureRecognizer(target: self, action: #selector(movePreviousDay))
    previousDayButtonView.addGestureRecognizer(tapGestureForPreviousDayButtonView)

    let tapGestureForNextMonthButtonView = UITapGestureRecognizer(target: self, action: #selector(moveNextMonth))
    nextMonthButtonView.addGestureRecognizer(tapGestureForNextMonthButtonView)

    let tapGestureForNextDayButtonView = UITapGestureRecognizer(target: self, action: #selector(moveNextDay))
    nextDayButtonView.addGestureRecognizer(tapGestureForNextDayButtonView)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadCollectionView(date: formatter.string(from: Date()))

    navigationController?.setNavigationBarHidden(true, animated: animated)
    updateTimeLabel()
  }

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "textInputSegue" {
      let viewController: TextInputViewController = segue.destination as! TextInputViewController
      viewController.date = dateLabel.text
      viewController.time = timeLabel.text
      viewController.day = dayLabel.text
      viewController.delegate = self
    } else if segue.identifier == "textModifySegue" {
      let viewController: TextModifyViewController = segue.destination as! TextModifyViewController
      viewController.date = dateLabel.text
      viewController.time = timeLabel.text
      viewController.existText = textSelected
      viewController.delegate = self
    }
  }

  @objc private func showAlarmList() {
    performSegue(withIdentifier: "showAlarmList", sender: self)
  }

  @objc private func showSettingViewController() {
    performSegue(withIdentifier: "showSetting", sender: self)
  }

  private func showAlarmSettingView() {
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 230))
    datePicker.datePickerMode = .dateAndTime
    datePicker.minimumDate = Date()
    datePicker.locale = Locale.init(identifier: Locale.current.languageCode!)
    datePicker.addTarget(self, action:
      #selector(MainViewController.dateSelected(datePicker:)), for: UIControl.Event.valueChanged)
    self.selectedDatePicked = datePicker.date // 이것을 넣은 이유는 selectedDatePicked가 처음에 값이 없기때문

    let appearance = SCLAlertView.SCLAppearance(
      kWindowWidth: datePicker.frame.size.width + 10.0, showCloseButton: false
    )

    let alertView = SCLAlertView(appearance: appearance)
    alertView.customSubview = datePicker
    alertView.addButton("DONE") {
      guard let text = self.textSelected else { return }

      text.alarmDatePicked = self.selectedDatePicked
      OnceTextManager().recordText(date: text.date, time: text.time, text: text)
      self.textAlarmTrigger(text: text, isAlarmSetting: true)
      AlarmManager().addNotification(textSelected: text, datePicked: self.selectedDatePicked, notificationType: .Once)
      self.collectionView.reloadData()

      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = UIColor.red
      message.text = "알람이 \(self.formatter2.string(from: datePicker.date))에 울립니다."

      let action = MDCSnackbarMessageAction()
      let actionHandler = {() in
        let answerMessage = MDCSnackbarMessage()
        answerMessage.text = "취소되었습니다."
        self.textAlarmTrigger(text: text, isAlarmSetting: false)
        AlarmManager().removeNotification(textSelected: self.textSelected!)
        MDCSnackbarManager.show(answerMessage)
      }
      action.handler = actionHandler
      action.title = "취소하기"
      message.action = action

      MDCSnackbarManager.show(message)

    }
    alertView.addButton("CANCEL", backgroundColor: UIColor.red) {

    }
    alertView.showTitle("알림설정", subTitle: "해당 키워드에 대해 알람을 설정하신 적이 있다면 지금 설정하는 것으로 최신화됩니다.", style: .notice)
  }

  private func textAlarmTrigger(text: Text, isAlarmSetting: Bool) {
    let textManager = OnceTextManager()
    if isAlarmSetting {
      text.onAlarmSetting()
    } else {
      text.offAlarmSetting()
    }
    textManager.recordText(date: text.date, time: text.time, text: text)
    reloadCollectionView(date: dateLabel.text!)
  }

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDatePicked = datePicker.date
  }

  func removeTapped() {
    let manager = OnceTextManager()
    manager.deleteText(date: dateLabel.text!, time: timeLabel.text!, text: textSelected!)
    reloadCollectionView(date: dateLabel.text!)
    calendarView.reloadData()
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(self.textSelected!.createdAt ?? "")"])
    textSelected = nil
    
  }

  func modifyTapped() {
    performSegue(withIdentifier: "textModifySegue", sender: self)
  }

  @IBAction func todayTapped(_ sender: Any) {
    let date = Date()
    Vibration.medium.vibrate()
    todayLabel.isHidden = false
    calendarView.select(date)
    reloadDataShowed(date: date)
    reloadCollectionView(date: formatter.string(from: date))
  }

  @IBAction func unwindMainViewController(segue: UIStoryboardSegue) {}

  private func collectionViewScrollToBottom() {
    let item = self.collectionView(self.collectionView!, numberOfItemsInSection: 0) - 1
    if item != -1 {
      let lastItemIndex = IndexPath(item: item, section: 0)
      self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
    }
  }

  deinit {
    if let timeChanger = self.timeChanger {
      timeChanger.invalidate()
    }
  }
}

// MARK: - collectionView와 관련된 함수
extension MainViewController {
  @objc func showInputTextViewController() {
    performSegue(withIdentifier: "textInputSegue", sender: self)
  }
}

// MARK: - 시간 보여주는 함수
extension MainViewController {
  @objc private func updateTimeLabel() {
    let format = DateFormatter()
    format.timeStyle = .medium
    timeLabel.text = format.string(from: clock.currentTime())
  }
}

// MARK: - FSCalendarDelegate 함수
extension MainViewController: FSCalendarDelegate {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    reloadDataShowed(date: date)
  }

  private func reloadDataShowed(date: Date) {
    let todayDate = formatter.string(from: Date())
    let selectDate = formatter.string(from: date)

    if todayDate == selectDate {
      todayLabel.isHidden = false
    } else {
      todayLabel.isHidden = true
    }

    dateLabel.text = selectDate
    dayLabel.text = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(selectDate))
    reloadCollectionView(date: selectDate)
  }
}

extension MainViewController: FSCalendarDataSource {
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let dateString = formatter.string(from: date)

    for dateItem in dateList {
      if dateItem.date == dateString {
        return 1
      }
    }
    return 0
  }
}

extension MainViewController: TextInputViewControllerDelegate, TextModifyViewControllerDelegate {
  func reloadCollectionView(date: String) {
    textList = OnceTextManager().loadTextList(date: date) + DailyTextManager().loadTextList()
    dateList = DateManager().loadDateList()
    collectionView.reloadData()
    collectionViewScrollToBottom()
  }

  func reloadCollectionViewAndCalendarView(date: String) {
    textList = OnceTextManager().loadTextList(date: date) + DailyTextManager().loadTextList()
    dateList = DateManager().loadDateList()
    collectionView.reloadData()
    calendarView.reloadData()
    collectionViewScrollToBottom()
  }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return textList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCollectionViewCell
    cell.textInstance = textList[indexPath.row]
    cell.descriptionLabel.text = textList[indexPath.row].string
    if textList[indexPath.row].isAlarmSetting {
      cell.descriptionLabel.textColor = UIColor.blue
    } else {
      cell.descriptionLabel.textColor = UIColor.black
    }
    cell.delegate = self
    return cell
  }
}

extension MainViewController: TextCollectionViewCellDelegate {
  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

    if let textAlarmDate = text.alarmDatePicked, text.isAlarmSetting {
      actionSheet.title = "알람 예정시간"
      actionSheet.message = "\(formatter2.string(from: textAlarmDate))"
    }
    let setAlarmAction = UIAlertAction(title: "Alarm", style: .default, handler: { (action) in
      self.showAlarmSettingView()
    })
    let deleteAlarm = UIAlertAction(title: "Remove Alarm", style: .default, handler: { (action) in
      if let text = self.textSelected {
        text.offAlarmSetting()
        OnceTextManager().recordText(date: text.date, time: text.time, text: text)
        AlarmManager().removeNotification(textSelected: text)
        self.reloadCollectionView(date: self.dateLabel.text!)
      }
    })
    let modifyAction = UIAlertAction(title: "Modify", style: .destructive, handler: {(action) in
      self.modifyTapped()
    })
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
      self.removeTapped()
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    if let text = textSelected, text.isAlarmSetting, text.repeatMode == .Once {
      actionSheet.addAction(deleteAlarm)
    } else if !text.isAlarmSetting, text.repeatMode == .Once {
      actionSheet.addAction(setAlarmAction)
    }
    actionSheet.addAction(modifyAction)
    actionSheet.addAction(deleteAction)
    actionSheet.addAction(cancelAction)

    present(actionSheet, animated: true, completion: nil)
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = textList[indexPath.row].string.height(withConstrainedWidth: UIScreen.main.bounds.width, font: UIFont(name: "Helvetica Neue", size: 17)!) + 10
    return CGSize(width: UIScreen.main.bounds.width, height: height)
  }
}

extension MainViewController {
  //MARK: move calender
  @objc private func moveNextDay() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: dateLabel.text!) else { return }
    guard let date = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func movePreviousDay() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: dateLabel.text!) else { return }
    guard let date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func moveNextMonth() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: dateLabel.text!) else { return }
    guard let date = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func movePreviousMonth() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: dateLabel.text!) else { return }
    guard let date = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }
}
