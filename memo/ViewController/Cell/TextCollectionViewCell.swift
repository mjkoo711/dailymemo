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
  func setAlarm(text: Text, type: NotificationType)
  func removeAlarm(text: Text)
  func reloadCollectionView(date: String)
}

class TextCollectionViewCell: UICollectionViewCell {
  var textInstance: Text?
  var currentDate: String?
  var isCompleted: Bool?

  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var checkImage: UIImageView!

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
    Vibration.success.vibrate()
    guard let currentDate = currentDate, let textInstance = textInstance, let isCompleted = isCompleted else { return }

    if isCompleted {
      FMDBManager.shared.deleteTextCompleted(text: textInstance, currentDate: currentDate)
    } else {
      FMDBManager.shared.insertTextCompleted(text: textInstance, currentDate: currentDate)
    }
    delegate?.reloadCollectionView(date: currentDate)
  }


  @objc func didDoubleTap() {
    guard let text = textInstance else { return }

    if text.isAlarmSetting == 0  {
      if text.repeatMode == .Once {
        Vibration.medium.vibrate()
        delegate?.setAlarm(text: textInstance!, type: .Once)
      } else if text.repeatMode == .Daily {
        Vibration.medium.vibrate()
        delegate?.setAlarm(text: textInstance!, type: .Daily)
      } else if text.repeatMode == .Weekly {
        Vibration.medium.vibrate()
        delegate?.setAlarm(text: textInstance!, type: .Weekly)
      } else if text.repeatMode == .Monthly {
        Vibration.medium.vibrate()
        delegate?.setAlarm(text: textInstance!, type: .Monthly)
      }
    } else if text.isAlarmSetting == 1 {
      Vibration.oldSchool.vibrate()

      let message = MDCSnackbarMessage()
      message.text = "Reminder was deleted.".localized
      MDCSnackbarManager.show(message)

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

