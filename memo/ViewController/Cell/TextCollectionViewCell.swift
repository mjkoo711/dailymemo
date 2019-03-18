//
//  TextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 02/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialSnackbar

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
    let singleTapGesture = UIShortTapGestureRecognizer(target: self, action: #selector(didPressPartButton))
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
    self.descriptionLabel.blink()
  }


  @objc func didDoubleTap() {
    guard let text = textInstance else { return }

    if text.repeatMode == .Once {
      if text.isAlarmSetting == 0 {
        Vibration.heavy.vibrate()
        delegate?.setAlarm(text: textInstance!)
      } else if text.repeatMode == .Daily {
        let message = MDCSnackbarMessage()
        message.text = "매일 반복되는 메모는 알람설정이 불가능합니다."
        MDCSnackbarManager.show(message)
      } else if text.repeatMode == .Weekly {
        let message = MDCSnackbarMessage()
        message.text = "매주 반복되는 메모는 알람설정이 불가능합니다."
        MDCSnackbarManager.show(message)
      } else if text.repeatMode == .Monthly {
        let message = MDCSnackbarMessage()
        message.text = "매월 반복되는 메모는 알람설정이 불가능합니다."
        MDCSnackbarManager.show(message)
      } else if text.isAlarmSetting == 1 {
        Vibration.oldSchool.vibrate()

        let message = MDCSnackbarMessage()
        message.text = "알람이 삭제되었습니다."
        MDCSnackbarManager.show(message)

        delegate?.removeAlarm(text: textInstance!)
      }
    }


  }

  @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizer.State.began {
      Vibration.success.vibrate()
      delegate?.showActionSheet(text: textInstance!)
    }
  }
}

