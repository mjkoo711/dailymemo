//
//  ViewController.swift
//  memo
//
//  Created by MinJun KOO on 25/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import FSCalendar

class ViewController: UIViewController {
  @IBOutlet var calendarView: FSCalendar!
  @IBOutlet var monthLabel: UILabel!
  @IBOutlet var dayLabel: UILabel!
  
  @IBOutlet var collectionView: UICollectionView!
  @IBOutlet weak var timeLabel: UILabel!

  fileprivate let gregorian = Calendar(identifier: .gregorian)
  fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  let clock = Clock()
  var timeChanger: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.placeholderType = .none
    monthLabel.text = formatter.string(from: Date())
    dayLabel.text = getStringDayOfWeek(weekDay: getDayOfWeek(formatter.string(from: Date())))

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGesture)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateTimeLabel()
  }

  @IBAction func todayTapped(_ sender: Any) {
    calendarView.setCurrentPage(Date(), animated: false)
    calendarView.select(Date())
    monthLabel.text = formatter.string(from: Date())
  }

  deinit {
    if let timeChanger = self.timeChanger {
      timeChanger.invalidate()
    }
  }
}

// MARK: - collectionView와 관련된 함수
extension ViewController {
  @objc func showInputTextViewController() {
    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InputTextViewController")
    viewController!.modalTransitionStyle = UIModalTransitionStyle.coverVertical
    viewController!.modalPresentationStyle = .overCurrentContext
    self.present(viewController!, animated: true, completion: nil)
  }
}

// MARK: - 시간 보여주는 함수
extension ViewController {
  @objc private func updateTimeLabel() {
    let format = DateFormatter()
    format.timeStyle = .medium
    timeLabel.text = format.string(from: clock.currentTime())
  }
}

// MARK: - FSCalendarDelegate 함수
extension ViewController: FSCalendarDelegate {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    monthLabel.text = formatter.string(from: date)
    dayLabel.text = getStringDayOfWeek(weekDay: getDayOfWeek(formatter.string(from: date)))
  }
}

// MARK: - 문자열 변환 함수
extension ViewController {
  private func getStringYear(year: String) -> String {
    switch year {
    case "01":
      return "January"
    case "02":
      return "Fabruary"
    case "03":
      return "March"
    case "04":
      return "April"
    case "05":
      return "May"
    case "06":
      return "June"
    case "07":
      return "July"
    case "08":
      return "August"
    case "09":
      return "September"
    case "10":
      return "October"
    case "11":
      return "November"
    case "12":
      return "December"
    default:
      return ""
    }
  }

  private func getStringDayOfWeek(weekDay: Int) -> String {
    switch weekDay {
    case 1:
      return "Sunday"
    case 2:
      return "Monday"
    case 3:
      return "Tuesday"
    case 4:
      return "Wednesday"
    case 5:
      return "Thursday"
    case 6:
      return "Friday"
    case 7:
      return "Saturday"
    default:
      return ""
    }
  }

  func getDayOfWeek(_ today:String) -> Int { // yyyy-MM-dd
    let todayDate = formatter.date(from: today)
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.weekday, from: todayDate!)
    return weekDay
  }
}
