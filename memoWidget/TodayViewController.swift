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

  override func viewDidLoad() {
    super.viewDidLoad()
    date = formatter.string(from: Date())
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    let textList = TextLoader().findOnceTextList(date: date) + TextLoader().findDailyTextList() + TextLoader().findWeeklyTextList(date: date) + TextLoader().findMonthlyTextList(date: date)
    completionHandler(NCUpdateResult.newData)
  }

}
