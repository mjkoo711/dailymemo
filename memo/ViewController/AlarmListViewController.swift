//
//  AlarmListViewController.swift
//  memo
//
//  Created by MinJun KOO on 04/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class AlarmListViewController: UIViewController {
  var setAlarmTextList: [Text] = []
  var alarmSortList: [(key: String, value: [Text])] = []

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
    cell.textLabel.text = alarmSortList[indexPath.section].value[indexPath.row].string
    cell.dateLabel.text = alarmSortList[indexPath.section].value[indexPath.row].date + "에 작성"
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
