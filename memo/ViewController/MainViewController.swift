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
import GoogleMobileAds
import MaterialComponents.MaterialSnackbar
import UserNotifications

class MainViewController: UIViewController {
  @IBOutlet var calendarView: FSCalendar!
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var dayLabel: UILabel!

  @IBOutlet var informationView: UIView!
  @IBOutlet var calendarHeightConstraint: NSLayoutConstraint!
  @IBOutlet var showSettingButtonView: UIView!
  @IBOutlet var showSettingButtonViewImage: UIImageView!

  @IBOutlet var showNewReleaseButtonView: UIView!
  @IBOutlet var showNewReleaseButtonViewImage: UIImageView!

  @IBOutlet var todayLabel: UILabel!

  @IBOutlet var expandView: UIView!
  @IBOutlet var expandImageButtonView: UIImageView!
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet var timeView: UIView!

  @IBOutlet var previousMonthButtonView: UIView!
  @IBOutlet var nextMonthButtonView: UIView!
  @IBOutlet var previousDayButtonView: UIView!
  @IBOutlet var nextDayButtonView: UIView!
  @IBOutlet var todayButtonView: UIView!

  @IBOutlet var previousMonthButtonViewImage: UIImageView!
  @IBOutlet var nextMonthButtonViewImage: UIImageView!
  @IBOutlet var previousDayButtonViewImage: UIImageView!
  @IBOutlet var nextDayButtonViewImage: UIImageView!
  @IBOutlet var todayButtonViewImage: UIImageView!

  @IBOutlet var bannerView: GADBannerView!
  private var selectDateString: String!
  private var selectDateObject: Date!
  private var selectDayString: String!
  private var selectDayInt: Int!

  fileprivate let formatter = MDateFormatter().formatter
  fileprivate let formatterKorea = MDateFormatter().formatterKorea
  fileprivate let formatterLocalized = MDateFormatter().formatterLocalized

  override var prefersStatusBarHidden: Bool {
    return true
  }

  let clock = Clock()
  var timeChanger: Timer?

  var textSelected: Text?

  var textList: [Text] = []
  var textCompletedList: [String] = []
  var selectedDateAlarmPicked: Date!
  var today: Date!

  override func viewDidLoad() {
    super.viewDidLoad()
    if let value = SettingManager.shared.purchaseMode {
      if value == .off {
        // TODO: 언젠간 광고를 띄우자 
//         loadBannerView()
      }
    }
    today = Date()
    if Locale.current.languageCode == "ko" {
      calendarView.appearance.headerDateFormat = "YYYY년 MM월"
    } else if Locale.current.languageCode == "ja" {
      calendarView.appearance.headerDateFormat = "YYYY年 MM月"
    } else {
      calendarView.appearance.headerDateFormat = "MMM YYYY"
    }
    calendarView.placeholderType = .none
    selectDateString = formatter.string(from: Date())
    selectDateObject = Date()
    selectDayString = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(formatter.string(from: Date())))
    selectDayInt = DateStringChanger().getDayOfWeek(formatter.string(from: Date()))

    dateLabel.text = DateStringChanger().dateFormatChange(dateWithHyphen: formatter.string(from: today))
    dayLabel.text = selectDayString

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.updateTimeLabel), userInfo: nil, repeats: true)

    changeCalendarMode()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(reloadTodayCollectionViewAndCalendarView),
                                           name: NSNotification.Name(rawValue: "ReloadCollectionView"),
                                           object: nil)

    let tapGestureForCollectionView = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGestureForCollectionView)

    informationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController)))
    informationView.isUserInteractionEnabled = true

    let tapGestureForSettingButtonView = UITapGestureRecognizer(target: self, action: #selector(showSettingViewController))
    showSettingButtonView.addGestureRecognizer(tapGestureForSettingButtonView)

    let tapGesgureForNewReleaseButtonView = UITapGestureRecognizer(target: self, action: #selector(showNewReleaseViewController) )
    showNewReleaseButtonView.addGestureRecognizer(tapGesgureForNewReleaseButtonView)

    let tapGestureForPreviousMonthButtonView = UITapGestureRecognizer(target: self, action: #selector(movePreviousMonth))
    previousMonthButtonView.addGestureRecognizer(tapGestureForPreviousMonthButtonView)

    let tapGestureForPreviousDayButtonView = UITapGestureRecognizer(target: self, action: #selector(movePreviousDay))
    previousDayButtonView.addGestureRecognizer(tapGestureForPreviousDayButtonView)

    let tapGestureForNextMonthButtonView = UITapGestureRecognizer(target: self, action: #selector(moveNextMonth))
    nextMonthButtonView.addGestureRecognizer(tapGestureForNextMonthButtonView)

    let tapGestureForNextDayButtonView = UITapGestureRecognizer(target: self, action: #selector(moveNextDay))
    nextDayButtonView.addGestureRecognizer(tapGestureForNextDayButtonView)

    let tapGestureForTodayButtonView = UITapGestureRecognizer(target: self, action: #selector(moveToday))
    todayButtonView.addGestureRecognizer(tapGestureForTodayButtonView)

    let swipeDownGestureForExpandButtonView = UISwipeGestureRecognizer(target: self, action: #selector(shrinkCalendar))
    swipeDownGestureForExpandButtonView.direction = .down
    expandView.addGestureRecognizer(swipeDownGestureForExpandButtonView)

    let swipeUpGestureForExpandButtonView = UISwipeGestureRecognizer(target: self, action: #selector(expandCalendar))
    swipeUpGestureForExpandButtonView.direction = .up
    expandView.addGestureRecognizer(swipeUpGestureForExpandButtonView)

    let tapGestureForExpandButtonView = UITapGestureRecognizer(target: self, action: #selector(toggleCalendar))
    expandView.addGestureRecognizer(tapGestureForExpandButtonView)
//    setFirstTimeDescription()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let value = SettingManager.shared.startKitMode, value == .on {
      WhatsNewAppHandler().showsWhatsNewApp(presentViewController: self)
    }
    reloadCollectionView(date: selectDateString)
    navigationController?.setNavigationBarHidden(true, animated: animated)
    updateTimeLabel()
    setTheme()
  }

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "textInputSegue" {
      let viewController: TextInputViewController = segue.destination as! TextInputViewController
      viewController.date = selectDateString
      viewController.time = timeLabel.text
      viewController.day = selectDayString
      viewController.delegate = self
    } else if segue.identifier == "textModifySegue" {
      let viewController: TextModifyViewController = segue.destination as! TextModifyViewController
      viewController.date = selectDateString
      viewController.time = timeLabel.text
      viewController.existText = textSelected
      viewController.delegate = self
    } else if segue.identifier == "showSetting" {
      let viewController: SettingViewController = segue.destination as! SettingViewController
      viewController.date = selectDateString
      viewController.delegate = self
    }
  }

  private func loadBannerView() {
    self.bannerView.adUnitID = Const.adUnitId
    self.bannerView.adSize = kGADAdSizeSmartBannerPortrait
    self.bannerView.rootViewController = self
    let request = GADRequest()
    #if DEBUG
    request.testDevices = [ "eb00b8743bf86e937aead12a47fe397a" ];
    #endif
    self.bannerView.load(request)
  }

  private func setTheme() {
    guard let value = SettingManager.shared.theme else { return }
    if value == .blackBlue || value == .blackRed { // Dark
      view.backgroundColor = Color.DarkModeMain
      setDayLabelTextColor()
      setDateLabelTextColor()
      calendarView.backgroundColor = Color.DarkModeMain
      collectionView.backgroundColor = Color.DarkModeSub
      informationView.backgroundColor = Color.DarkModeSub
      calendarView.appearance.headerTitleColor = Color.White
      if value == .blackRed {
        timeView.backgroundColor = Color.LightRed
        calendarView.appearance.todayColor = Color.LightRed
        expandView.backgroundColor = Color.LightRed
        todayLabel.backgroundColor = Color.LightRed
      } else if value == .blackBlue {
        timeView.backgroundColor = Color.Blue
        calendarView.appearance.todayColor = Color.Blue
        expandView.backgroundColor = Color.Blue
        todayLabel.backgroundColor = Color.Blue
      }
      showSettingButtonViewImage.image = UIImage(named: "SettingWhite")
      showNewReleaseButtonViewImage.image = UIImage(named: "ReleaseWhite")
      previousMonthButtonViewImage.image = UIImage(named: "MoreLeftWhite")
      previousDayButtonViewImage.image = UIImage(named: "LeftWhite")
      todayButtonViewImage.image = UIImage(named: "TodayWhite")
      nextDayButtonViewImage.image = UIImage(named: "RightWhite")
      nextMonthButtonViewImage.image = UIImage(named: "MoreRightWhite")


      for index in 0..<calendarView.calendarWeekdayView.weekdayLabels.count {
        let label = calendarView.calendarWeekdayView.weekdayLabels[index]
        if index == 0 {
          label.textColor = Color.LightRed
        } else if index == 6 {
          label.textColor = Color.Blue
        } else {
          label.textColor = Color.DarkModeFontColor
        }
      }
    } else if value == .whiteRed || value == .whiteBlue { // White
      view.backgroundColor = Color.WhiteModeMain
      setDayLabelTextColor()
      setDateLabelTextColor()
      calendarView.backgroundColor = Color.WhiteModeMain
      collectionView.backgroundColor = Color.WhiteModeSub
      informationView.backgroundColor = Color.WhiteModeSub
      calendarView.appearance.headerTitleColor = Color.Black

      if value == .whiteRed {
        timeView.backgroundColor = Color.LightRed
        calendarView.appearance.todayColor = Color.LightRed
        expandView.backgroundColor = Color.LightRed
        todayLabel.backgroundColor = Color.LightRed
      } else if value == .whiteBlue {
        timeView.backgroundColor = Color.Blue
        calendarView.appearance.todayColor = Color.Blue
        expandView.backgroundColor = Color.Blue
        todayLabel.backgroundColor = Color.Blue
      }
      showSettingButtonViewImage.image = UIImage(named: "Setting")
      showNewReleaseButtonViewImage.image = UIImage(named: "Release")
      previousMonthButtonViewImage.image = UIImage(named: "MoreLeft")
      previousDayButtonViewImage.image = UIImage(named: "Left")
      todayButtonViewImage.image = UIImage(named: "Today")
      nextDayButtonViewImage.image = UIImage(named: "Right")
      nextMonthButtonViewImage.image = UIImage(named: "MoreRight")

      for index in 0..<calendarView.calendarWeekdayView.weekdayLabels.count {
        let label = calendarView.calendarWeekdayView.weekdayLabels[index]
        if index == 0 {
          label.textColor = Color.LightRed
        } else if index == 6 {
          label.textColor = Color.Blue
        } else {
          label.textColor = Color.WhiteModeFontColor
        }
      }
    }
  }

  @objc private func showAlarmList() {
    Vibration.medium.vibrate()
    performSegue(withIdentifier: "showAlarmList", sender: self)
  }

  @objc private func showSettingViewController() {
    Vibration.medium.vibrate()
    performSegue(withIdentifier: "showSetting", sender: self)
  }

  @objc private func showNewReleaseViewController() {
    Vibration.medium.vibrate()
    WhatsNewAppHandler().showsWhatsNewApp(presentViewController: self)
  }

  private func showAlarmSettingView(type: NotificationType) {
    let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 230))
    datePicker.datePickerMode = .dateAndTime
    datePicker.minimumDate = Date()
    datePicker.setDate(selectDateObject, animated: true)
    datePicker.locale = Locale.init(identifier: Locale.current.languageCode!)
    datePicker.addTarget(self, action:
      #selector(MainViewController.dateSelected(datePicker:)), for: UIControl.Event.valueChanged)
    self.selectedDateAlarmPicked = datePicker.date // 이것을 넣은 이유는 selectedDatePicked가 처음에 값이 없기때문

    let appearance = SCLAlertView.SCLAppearance(
      kWindowWidth: datePicker.frame.size.width + 10.0, showCloseButton: false
    )

    let alertView = SCLAlertView(appearance: appearance)
    alertView.customSubview = datePicker
    alertView.addButton("DONE".localized) {
      guard let text = self.textSelected else { return }

      text.alarmDatePicked = self.selectedDateAlarmPicked
      self.textAlarmTrigger(text: text, isAlarmSetting: true)
      AlarmManager().addNotification(textSelected: text, datePicked: self.selectedDateAlarmPicked, notificationType: type)
      self.reloadCollectionView(date: self.selectDateString)
      // MARK: snackbar
      let message = MDCSnackbarMessage()
      message.buttonTextColor = Color.LightRed
      if type == .Once {
        message.text = "The reminder rings once at the set time.".localized
      } else if type == .Daily {
        message.text = "The reminder rings every day at the set time.".localized
      } else if type == .Weekly {
        message.text = "The reminder rings every week at the set time.".localized
      } else if type == .Monthly {
        message.text = "The reminder rings every month at the set time.".localized
      }

      let action = MDCSnackbarMessageAction()
      let actionHandler = {() in
        let answerMessage = MDCSnackbarMessage()
        answerMessage.text = "Canceled".localized
        self.textAlarmTrigger(text: text, isAlarmSetting: false)
        AlarmManager().removeNotification(textSelected: self.textSelected!)
        MDCSnackbarManager.show(answerMessage)
      }
      action.handler = actionHandler
      action.title = "CANCEL".localized
      message.action = action

      MDCSnackbarManager.show(message)

    }
    alertView.addButton("CANCEL".localized, backgroundColor: Color.LightRed) {

    }
    alertView.showCustom("Reminder Settings".localized, subTitle: "", color: Color.Blue, icon: UIImage(named: "AlarmOnWhite")!)
  }

  private func textAlarmTrigger(text: Text, isAlarmSetting: Bool) {
    if isAlarmSetting {
      text.onAlarmSetting()
    } else {
      text.offAlarmSetting()
    }
    FMDBManager.shared.updateText(text: text)
    reloadCollectionView(date: selectDateString)
  }

  @objc private func dateSelected(datePicker: UIDatePicker) {
    selectedDateAlarmPicked = datePicker.date
  }

  func removeTapped() {
    guard let textSelected = self.textSelected else { return }

    FMDBManager.shared.deleteText(text: textSelected)
    reloadCollectionViewAndCalendarView(date: selectDateString)
    AlarmManager().removeNotification(textSelected: textSelected)
    self.textSelected = nil
  }

  func modifyTapped() {
    performSegue(withIdentifier: "textModifySegue", sender: self)
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
    Vibration.medium.vibrate()
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
    Vibration.medium.vibrate()
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
    selectDateString = selectDate
    selectDateObject = date
    selectDayString = DateStringChanger().getStringDayOfWeek(weekDay: DateStringChanger().getDayOfWeek(selectDate))
    selectDayInt = DateStringChanger().getDayOfWeek(selectDate)

    dateLabel.text = DateStringChanger().dateFormatChange(dateWithHyphen: formatter.string(from: date))
    dayLabel.text = selectDayString
    setDayLabelTextColor()
    setDateLabelTextColor()
    reloadCollectionView(date: selectDate)
  }

  private func setDayLabelTextColor() {
    guard let value = SettingManager.shared.theme else { return }

    if value == .whiteRed || value == .whiteBlue { // White
      if selectDayInt == 1 {
        dayLabel.textColor = Color.LightRed
      } else if selectDayInt == 7 {
        dayLabel.textColor = Color.Blue
      } else {
        dayLabel.textColor = Color.WhiteModeFontColor
      }
    } else if value == .blackRed || value == .blackBlue {
      if selectDayInt == 1 {
        dayLabel.textColor = Color.LightRed
      } else if selectDayInt == 7 {
        dayLabel.textColor = Color.Blue
      } else {
        dayLabel.textColor = Color.DarkModeFontColor
      }
    }
  }

  private func setDateLabelTextColor() {
    guard let value = SettingManager.shared.theme else { return }

    if value == .whiteRed || value == .whiteBlue { // White
      dateLabel.textColor = .black
    } else if value == .blackRed || value == .blackBlue {
      dateLabel.textColor = .white
    }
  }

  private func checkCalendarEventColor(date: Date) -> [UIColor]? {
    let dateString = formatter.string(from: date)
    let dateList = DateLoader().findOnceDateList()

    if TextLoader().findDailyTextList().count != 0 {
      if let value = SettingManager.shared.theme {
        if value == .blackRed || value == .whiteRed {
          return [Color.LightRed]
        } else {
          return [Color.Blue]
        }
      }
    }

    if TextLoader().findWeeklyTextList(date: dateString).count != 0 {
      if let value = SettingManager.shared.theme {
        if value == .blackRed || value == .whiteRed {
          return [Color.LightRed]
        } else {
          return [Color.Blue]
        }
      }
    }

    if TextLoader().findMonthlyTextList(date: dateString).count != 0 {
      if let value = SettingManager.shared.theme {
        if value == .blackRed || value == .whiteRed {
          return [Color.LightRed]
        } else {
          return [Color.Blue]
        }
      }
    }

    for dateItem in dateList {
      if dateItem == dateString {
        if let value = SettingManager.shared.theme {
          if value == .blackRed || value == .whiteRed {
            return [Color.LightRed]
          } else {
            return [Color.Blue]
          }
        }
      }
    }

    return nil
  }
}

extension MainViewController: FSCalendarDataSource {
  func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
    var count = 0
    let dateString = formatter.string(from: date)
    let dateList = DateLoader().findOnceDateList()

    if TextLoader().findDailyTextList().count != 0 { count = count + 1 }
    if TextLoader().findWeeklyTextList(date: dateString).count != 0 { count = count + 1 }
    if TextLoader().findMonthlyTextList(date: dateString).count != 0 { count = count + 1 }

    for dateItem in dateList {
      if dateItem == dateString {
        count = count + 1
        break
      }
    }
    return count
  }

  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
    return checkCalendarEventColor(date: date)
  }

  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
    return checkCalendarEventColor(date: date)
  }

  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    if let value = SettingManager.shared.theme {
      if formatter.string(from: date) == formatter.string(from: calendar.today ?? today) {
        return Color.White
      }
      if value == .blackRed || value == .blackBlue {
        return Color.DarkModeFontColor
      } else {
        return Color.WhiteModeFontColor
      }
    }
    return nil
  }

  func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    calendarHeightConstraint.constant = bounds.size.height
    collectionView.layoutIfNeeded()
  }

  // MARK: select date border color
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
    return nil
  }

  // MARK: select date font color
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
    if let value = SettingManager.shared.theme {
      if value == .blackBlue || value == .blackRed {
        return .white
      } else if value == .whiteBlue || value == .whiteRed {
        return .white
      }
    }
    return nil
  }

  // MAKR : select date fill color
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
    if let value = SettingManager.shared.theme {
      if value == .blackBlue || value == .blackRed {
        if date == calendar.today || date == today {
          if value == .blackBlue {
            return Color.Blue
          } else if value == .blackRed {
            return Color.LightRed
          }
        }
        return Color.DarkGray
      } else  if value == .whiteBlue || value == .whiteRed {
        if date == calendar.today || date == today {
          if value == .whiteBlue {
            return Color.Blue
          } else if value == .whiteRed {
            return Color.LightRed
          }
        }
        return Color.LightGray
      }
    }
    return nil
  }
}

extension MainViewController: FSCalendarDelegateAppearance {
}

extension MainViewController: TextInputViewControllerDelegate, TextModifyViewControllerDelegate, SettingViewControllerDelegate {
  func changeCalendarMode() {
    if SettingManager.shared.calendarMode == CalendarMode.week {
      calendarView.scope = .week
      expandImageButtonView.image = UIImage(named: "UpWhite")
    } else if SettingManager.shared.calendarMode == CalendarMode.month {
      calendarView.scope = .month
      expandImageButtonView.image = UIImage(named: "DownWhite")
    }
  }

  func changeMainViewControllerTheme() {
    setTheme()
  }

  func removeBanner() {
    bannerView.isHidden = true
  }

  @objc func reloadTodayCollectionViewAndCalendarView() {
    today = Date()
    var date = ""
    if let selectDateStr = selectDateString {
      date = selectDateStr
    } else {
      date = formatter.string(from: Date())
    }
    textList = TextLoader().findOnceTextList(date: date) + TextLoader().findDailyTextList() + TextLoader().findWeeklyTextList(date: date) + TextLoader().findMonthlyTextList(date: date)
    textCompletedList = FMDBManager.shared.findTextCompleted(currentDate: selectDateString)

    collectionView.reloadData()
    calendarView.reloadData()
    collectionViewScrollToBottom()
  }

  func reloadCollectionView(date: String) {
    today = Date()
    textList = TextLoader().findOnceTextList(date: date) + TextLoader().findDailyTextList() + TextLoader().findWeeklyTextList(date: date) + TextLoader().findMonthlyTextList(date: date)
    textCompletedList = FMDBManager.shared.findTextCompleted(currentDate: selectDateString)

    collectionView.reloadData()
    collectionViewScrollToBottom()
  }

  @objc func reloadCollectionViewAndCalendarView(date: String) {
    today = Date()
    textList = TextLoader().findOnceTextList(date: date) + TextLoader().findDailyTextList() + TextLoader().findWeeklyTextList(date: date) + TextLoader().findMonthlyTextList(date: date)
    textCompletedList = FMDBManager.shared.findTextCompleted(currentDate: selectDateString)

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

    if let fontSize = SettingManager.shared.fontSize,
      let fontWeight = SettingManager.shared.fontWeight {
      cell.descriptionLabel.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
    }

    if let lineBreak = SettingManager.shared.lineBreak {
      if lineBreak == .off {
        cell.descriptionLabel.lineBreakMode = .byCharWrapping
      } else {
        cell.descriptionLabel.lineBreakMode = .byWordWrapping
      }
    }

    guard let theme = SettingManager.shared.theme else { return cell }

    if theme == .blackBlue || theme == .blackRed {
      cell.descriptionLabel.textColor = Color.DarkModeFontColor
    } else if theme == .whiteRed || theme == .whiteBlue {
      cell.descriptionLabel.textColor = Color.WhiteModeFontColor
    }

    cell.textInstance = textList[indexPath.row]
    cell.descriptionLabel.text = textList[indexPath.row].string
    cell.currentDate = selectDateString

    if textCompletedList.contains(textList[indexPath.row].createdAt) {
      cell.isCompleted = true
      if theme == .blackBlue || theme == .blackRed {
        cell.checkImage.image = UIImage(named: "CheckBoxWhite")
      } else if theme == .whiteBlue || theme == .whiteRed {
        cell.checkImage.image = UIImage(named: "CheckBox")
      }
    } else {
      cell.isCompleted = false
      if theme == .blackBlue || theme == .blackRed {
        cell.checkImage.image = UIImage(named: "UncheckBoxWhite")
      } else if theme == .whiteBlue || theme == .whiteRed {
        cell.checkImage.image = UIImage(named: "UncheckBox")
      }
    }

    if textList[indexPath.row].isAlarmable() {
      if theme == .whiteBlue || theme == .blackBlue {
        cell.descriptionLabel.textColor = Color.Blue
      } else if theme == .whiteRed || theme == .blackRed {
        cell.descriptionLabel.textColor = Color.LightRed
      }
    } else {
      if theme == .whiteBlue || theme == .whiteRed {
        cell.descriptionLabel.textColor = Color.WhiteModeFontColor
      } else if theme == .blackRed || theme == .blackBlue {
        cell.descriptionLabel.textColor = Color.DarkModeFontColor
      }
    }
    cell.delegate = self
    return cell
  }
}

extension MainViewController: TextCollectionViewCellDelegate {
  func setAlarm(text: Text, type: NotificationType) {
    textSelected = text
    self.showAlarmSettingView(type: type)
  }

  func removeAlarm(text: Text) {
    text.alarmDatePicked = nil
    textSelected = text
    text.offAlarmSetting()
    FMDBManager.shared.updateText(text: text)
    AlarmManager().removeNotification(textSelected: text)
    self.reloadCollectionView(date: self.selectDateString)
  }

  func showActionSheet(text: Text) {
    textSelected = text

    let actionSheet = UIAlertController(title: text.string, message: "No Upcoming Reminder".localized, preferredStyle: .actionSheet)

    if let textAlarmDate = text.alarmDatePicked, text.isAlarmable() {
      actionSheet.title = text.string
      actionSheet.message =  "Reminder Time".localized + "\n" + "\(formatterLocalized.string(from: textAlarmDate))"
    }
//
//    if !text.isAlarmable() && text.repeatMode != .Once {
//      actionSheet.message = "You can not set reminders for repeatedly saved memo.".localized
//    }

    let modifyAlarmAction = UIAlertAction(title: "Modify Reminder".localized, style: .default, handler: { (action) in
      if text.repeatMode == .Once {
        self.showAlarmSettingView(type: .Once)
      } else if text.repeatMode == .Daily {
        self.showAlarmSettingView(type: .Daily)
      } else if text.repeatMode == .Weekly {
        self.showAlarmSettingView(type: .Weekly)
      } else if text.repeatMode == .Monthly {
        self.showAlarmSettingView(type: .Monthly)
      }
    })

    let copyAction = UIAlertAction(title: "Copy".localized, style: .default, handler: { (action) in
      UIPasteboard.general.string = text.string
      let message = MDCSnackbarMessage()
      message.text = "Copied.".localized
      MDCSnackbarManager.show(message)
    })

    let modifyAction = UIAlertAction(title: "Modify".localized, style: .default, handler: { (action) in
      self.modifyTapped()
    })

    let deleteAction = UIAlertAction(title: "Delete".localized, style: .destructive, handler: {(action) in
      self.removeTapped()
      let message = MDCSnackbarMessage()
      message.text = "Deleted.".localized
      MDCSnackbarManager.show(message)
    })

    let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)

    if text.isAlarmable() {
      actionSheet.addAction(modifyAlarmAction)
    }
    actionSheet.addAction(copyAction)
    actionSheet.addAction(modifyAction)
    actionSheet.addAction(deleteAction)
    actionSheet.addAction(cancelAction)

    present(actionSheet, animated: true, completion: nil)
  }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = textList[indexPath.row].string.height(withConstrainedWidth: UIScreen.main.bounds.width - 60, font: UIFont.systemFont(ofSize: SettingManager.shared.fontSize!, weight: SettingManager.shared.fontWeight!)) + 8
    return CGSize(width: UIScreen.main.bounds.width - 25, height: height)
  }
}

extension MainViewController {
  //MARK: move calender
  @objc private func moveToday() {
    Vibration.medium.vibrate()
    let date = Date()
    todayLabel.isHidden = false
    calendarView.select(date)
    reloadDataShowed(date: date)
  }

  @objc private func moveNextDay() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: selectDateString) else { return }
    guard let date = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func movePreviousDay() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: selectDateString) else { return }
    guard let date = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func moveNextMonth() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: selectDateString) else { return }
    guard let date = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func movePreviousMonth() {
    Vibration.medium.vibrate()
    guard let currentDate = formatter.date(from: selectDateString) else { return }
    guard let date = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return }
    calendarView.select(date, scrollToDate: true)
    reloadDataShowed(date: date)
  }

  @objc private func shrinkCalendar(_ sender: UISwipeGestureRecognizer) {
    Vibration.medium.vibrate()
    if calendarView.scope == .month && sender.direction == .down {
      calendarView.scope = .week
      expandImageButtonView.image = UIImage(named: "UpWhite")
    }
  }

  @objc private func expandCalendar(_ sender: UISwipeGestureRecognizer) {
    Vibration.medium.vibrate()
    if calendarView.scope == .week && sender.direction == .up  {
      calendarView.scope = .month
      expandImageButtonView.image = UIImage(named: "DownWhite")
    }
  }

  @objc private func toggleCalendar(_ sender: UITapGestureRecognizer) {
    Vibration.medium.vibrate()
    if calendarView.scope == .week {
      calendarView.scope = .month
      expandImageButtonView.image = UIImage(named: "DownWhite")
    } else if calendarView.scope == .month {
      calendarView.scope = .week
      expandImageButtonView.image = UIImage(named: "UpWhite")
    }
  }
}
