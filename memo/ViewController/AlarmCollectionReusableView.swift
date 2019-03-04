//
//  AlarmCollectionReusableView.swift
//  memo
//
//  Created by MinJun KOO on 04/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class AlarmCollectionReusableView: UICollectionReusableView {
  @IBOutlet weak var alarmTimeLabel: UILabel!
  var alarmTime: String! {
    didSet {
      alarmTimeLabel.text = alarmTime
    }
  }
}
