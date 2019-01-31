//
//  MainViewController.swift
//  memo
//
//  Created by MinJun KOO on 25/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import FSCalendar

class MainViewController: UIViewController {
  @IBOutlet var calendarView: FSCalendar!
  @IBOutlet var monthLabel: UILabel!
  @IBOutlet var dayLabel: UILabel!

  @IBOutlet var todayLabel: UILabel!

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

  var textList: [Text] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    calendarView.placeholderType = .none
    monthLabel.text = formatter.string(from: Date())
    dayLabel.text = DateManager().getStringDayOfWeek(weekDay: DateManager().getDayOfWeek(formatter.string(from: Date())))

    timeChanger = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(MainViewController.updateTimeLabel), userInfo: nil, repeats: true)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showInputTextViewController))
    collectionView.addGestureRecognizer(tapGesture)
    reloadCollectionView(date: formatter.string(from: Date()))
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
    todayLabel.isHidden = false
    calendarView.setCurrentPage(Date(), animated: false)
    calendarView.select(Date())
    monthLabel.text = formatter.string(from: Date())
    dayLabel.text = DateManager().getStringDayOfWeek(weekDay: DateManager().getDayOfWeek(formatter.string(from: Date())))
    reloadCollectionView(date: formatter.string(from: Date()))
  }

  @IBAction func unwindMainViewController(segue: UIStoryboardSegue) {}

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
    dayLabel.text = DateManager().getStringDayOfWeek(weekDay: DateManager().getDayOfWeek(selectDay))
    reloadCollectionView(date: selectDay)
  }
}

extension MainViewController: TextInputViewControllerDelegate {
  func reloadCollectionView(date: String) {
    textList = TextManager().loadTextList(key: date)
    collectionView.reloadData()
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "textInputSegue" {
      let viewController: TextInputViewController = segue.destination as! TextInputViewController
      viewController.date = monthLabel.text
      viewController.time = timeLabel.text
      viewController.delegate = self
    }
  }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return textList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell", for: indexPath) as! TextCollectionViewCell

    cell.textLabel.text = textList[indexPath.row].string
    return cell
  }
}