//
//  AlarmCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 04/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol AlarmCollectionViewCellDelegate {
  func showActionSheet(text: Text)
}

class AlarmCollectionViewCell: UICollectionViewCell {
  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var textLabel: UILabel!
  var textInstance: Text?
  var delegate: AlarmCollectionViewCellDelegate?

  override func awakeFromNib() {
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.addGestureRecognizer(longPressGesture)
  }

  @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizer.State.began {
      Vibration.success.vibrate()
      delegate?.showActionSheet(text: textInstance!)
    }
  }
}
