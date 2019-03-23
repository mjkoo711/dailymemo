//
//  TodayViewController.swift
//  memoWidget
//
//  Created by MinJun KOO on 20/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
  let formatter = MDateFormatter().formatter
  var date: String!
  var textList: [Text] = []
  var textCompletedList: [String] = []

  @IBOutlet var collectionView: UICollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    date = formatter.string(from: Date())
    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    date = formatter.string(from: Date())
    reloadCollectionView(date: date)
    completionHandler(NCUpdateResult.newData)
  }

  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == .expanded {
      preferredContentSize = collectionView.contentSize
    } else {
      preferredContentSize = maxSize
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    date = formatter.string(from: Date())
  }
}

extension TodayViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return textList.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TextCell2", for: indexPath) as! WidgetTextCollectionViewCell

    cell.descriptionLabel.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    cell.descriptionLabel.textColor = Color.Black

    cell.textInstance = textList[indexPath.row]
    cell.descriptionLabel.text = textList[indexPath.row].string
    cell.currentDate = date
    cell.delegate = self

    if textCompletedList.contains(textList[indexPath.row].createdAt) {
      cell.isCompleted = true
      cell.checkImage.image = UIImage(named: "CheckBox")
    } else {
      cell.isCompleted = false
      cell.checkImage.image = UIImage(named: "UncheckBox")
    }

    return cell
  }

  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let widgetTitleHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WidgetCollectionReusableView", for: indexPath) as! WidgetCollectionReusableView
    widgetTitleHeaderView.delegate = self

    return widgetTitleHeaderView
  }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let height = textList[indexPath.row].string.height(withConstrainedWidth: UIScreen.main.bounds.width - 57, font: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.medium)) + 8
    return CGSize(width: UIScreen.main.bounds.width - 25, height: height)
  }
}

extension TodayViewController: WidgetTextCollectionViewCellDelegate {
  func reloadCollectionView(date: String) {
    textList = TextLoader().findOnceTextList(date: date) + TextLoader().findDailyTextList() + TextLoader().findWeeklyTextList(date: date) + TextLoader().findMonthlyTextList(date: date)
    textCompletedList = FMDBManager.shared.findTextCompleted(currentDate: date)
    collectionView.reloadData()
    collectionView.layoutIfNeeded()
    preferredContentSize.height = collectionView.contentSize.height
  }
}

extension TodayViewController: WidgetCollectionReusableViewDelegate {
  func goApp() {
    guard let appURL = URL(string: "mjkooMemo://") else { return }
    self.extensionContext?.open(appURL, completionHandler: nil)
  }
}
