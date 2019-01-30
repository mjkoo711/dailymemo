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
    dayLabel.text = DateManager().getStringDayOfWeek(weekDay: DateManager().getDayOfWeek(formatter.string(from: Date())))

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ViewController.updateTimeLabel), userInfo: nil, repeats: true)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGesture)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateTimeLabel()
    let textManager = TextManager()
    if let date = monthLabel.text {
      let temp: [Text] = textManager.loadTextList(key: date)
      dump(temp)
    }
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
    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "InputTextViewController") as! TextInputViewController
    viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
    viewController.modalPresentationStyle = .overCurrentContext
    viewController.date = monthLabel.text
    viewController.time = timeLabel.text
    self.present(viewController, animated: false, completion: nil)
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
    dayLabel.text = DateManager().getStringDayOfWeek(weekDay: DateManager().getDayOfWeek(formatter.string(from: date)))
  }
}
