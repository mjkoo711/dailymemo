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
  
  fileprivate let gregorian = Calendar(identifier: .gregorian)
  fileprivate let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.placeholderType = .none
    monthLabel.text = formatter.string(from: Date())
    dayLabel.text = getStringDayOfWeek(weekDay: getDayOfWeek(formatter.string(from: Date())))
  }

  @IBAction func todayTapped(_ sender: Any) {
    print("HI")
    calendarView.setCurrentPage(Date(), animated: false)
    calendarView.select(Date())
    monthLabel.text = formatter.string(from: Date())
  }
}

extension ViewController: FSCalendarDelegate {
  func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    monthLabel.text = formatter.string(from: date)
    dayLabel.text = getStringDayOfWeek(weekDay: getDayOfWeek(formatter.string(from: date)))
  }
}

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
