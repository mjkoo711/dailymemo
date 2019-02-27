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
  @IBOutlet var monthLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!

  @IBOutlet var todayLabel: UILabel!

  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet weak var timeLabel: UILabel!

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
  var dayList: [Day] = []

  var selectedDatePicked: Date!

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.placeholderType = .none
    monthLabel.text = formatter.string(from: Date())
    dateLabel.text = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(formatter.string(from: Date())))

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.updateTimeLabel), userInfo: nil, repeats: true)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGesture)
    reloadCollectionView(date: formatter.string(from: Date()))
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateTimeLabel()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "textInputSegue" {
      let viewController: TextInputViewController = segue.destination as! TextInputViewController
      viewController.date = monthLabel.text
      viewController.time = timeLabel.text
      viewController.delegate = self
    } else if segue.identifier == "textModifySegue" {
      let viewController: TextModifyViewController = segue.destination as! TextModifyViewController
      viewController.date = monthLabel.text
      viewController.time = timeLabel.text
      viewController.existText = textSelected
      viewController.delegate = self
    }
  }

  private func showAlarmSettingView() {
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 230))
    datePicker.datePickerMode = .dateAndTime
    datePicker.minimumDate = Date()
    datePicker.locale = Locale.init(identifier: Locale.current.languageCode!)
    datePicker.addTarget(self, action:
      #selector(MainViewController.dateSelected(datePicker:)), for: UIControl.Event.valueChanged)

    let appearance = SCLAlertView.SCLAppearance(
      kWindowWidth: datePicker.frame.size.width + 10.0, showCloseButton: false
    )

    let alertView = SCLAlertView(appearance: appearance)
    alertView.customSubview = datePicker

    weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    alertView.addButton("DONE") {
      appDelegate?.showEduNotification(textSelected: self.textSelected!, datePicked: self.selectedDatePicked, notificationType: .Once)

      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = UIColor.red
      message.text = "알람이 \(self.formatter2.string(from: datePicker.date))에 울립니다."

      let action = MDCSnackbarMessageAction()
      let actionHandler = {() in
        let answerMessage = MDCSnackbarMessage()
        answerMessage.text = "취소되었습니다."
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(self.textSelected!.createdAt ?? "")"])
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

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDatePicked = datePicker.date
  }

  func removeTapped() {
    let manager = TextManager()
    manager.deleteText(date: monthLabel.text!, time: timeLabel.text!, text: textSelected!)
    reloadCollectionView(date: monthLabel.text!)
    calendarView.reloadData()
    textSelected = nil
  }

  func modifyTapped() {
    performSegue(withIdentifier: "textModifySegue", sender: self)
  }

  @IBAction func todayTapped(_ sender: Any) {
    Vibration.medium.vibrate()
    todayLabel.isHidden = false
    calendarView.setCurrentPage(Date(), animated: false)
    calendarView.select(Date())
    monthLabel.text = formatter.string(from: Date())
    dateLabel.text = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(formatter.string(from: Date())))
    reloadCollectionView(date: formatter.string(from: Date()))
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
    let today = formatter.string(from: Date())
    let selectDay = formatter.string(from: date)

    if today == selectDay {
      todayLabel.isHidden = false
    } else {
      todayLabel.isHidden = true
    }

    monthLabel.text = selectDay
    dateLabel.text = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(selectDay))
    reloadCollectionView(date: selectDay)
  }
}

extension MainViewController: FSCalendarDataSource {
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    let dateString = formatter.string(from: date)

    for day in dayList {
      if day.date == dateString {
        return 1
      }
    }
    return 0
  }
}

extension MainViewController: TextInputViewControllerDelegate, TextModifyViewControllerDelegate {
  func reloadCollectionView(date: String) {
    textList = TextManager().loadTextList(date: date)
    dayList = DayManager().loadDayList()
    collectionView.reloadData()
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
    cell.delegate = self
    return cell
  }
}

extension MainViewController: TextCollectionViewCellDelegate {
  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let setAlarmAction = UIAlertAction(title: "Alarm", style: .default, handler: { (action) in
      self.showAlarmSettingView()
    })
    let modifyAction = UIAlertAction(title: "Modify", style: .destructive, handler: {(action) in
      self.modifyTapped()
    })
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: {(action) in
      self.removeTapped()
    })
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

    actionSheet.addAction(setAlarmAction)
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
