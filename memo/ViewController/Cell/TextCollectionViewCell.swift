//
//  TextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 02/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol TextCollectionViewCellDelegate {
  func showActionSheet(text: Text)
  func setAlarm(text: Text)
  func removeAlarm(text: Text)
}

class TextCollectionViewCell: UICollectionViewCell {
  var textInstance: Text?
  @IBOutlet var descriptionLabel: UILabel!

  var delegate: TextCollectionViewCellDelegate?
  
  override func awakeFromNib() {
    let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didPressPartButton))
    singleTapGesture.numberOfTapsRequired = 1
    self.addGestureRecognizer(singleTapGesture)

    let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
    doubleTapGesture.numberOfTapsRequired = 2
    self.addGestureRecognizer(doubleTapGesture)
    singleTapGesture.require(toFail: doubleTapGesture)

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.addGestureRecognizer(longPressGesture)
  }

  @objc func didPressPartButton() {

  }

  @objc func didDoubleTap() {
    if let text = textInstance, text.isAlarmSetting == 0 {
      Vibration.error.vibrate()
      delegate?.setAlarm(text: textInstance!)
    }
    
    if let text = textInstance, text.isAlarmSetting == 1 {
      Vibration.oldSchool.vibrate()
      delegate?.removeAlarm(text: textInstance!)
    }
  }
  @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizer.State.began {
      Vibration.success.vibrate()
      delegate?.showActionSheet(text: textInstance!)
    }
  }
}
