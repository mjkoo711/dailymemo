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
  func deleteAlarmText(text: Text)
}

class AlarmCollectionViewCell: UICollectionViewCell {
  @IBOutlet var deleteButtonView: UIView!
  @IBOutlet var parentView: UIView!

  @IBOutlet var dateLabel: UILabel!
  @IBOutlet var textLabel: UILabel!
  var textInstance: Text?
  var delegate: AlarmCollectionViewCellDelegate?

  override func layoutSubviews() {
    super.layoutSubviews()
    deleteButtonView.roundCorners(corners: [.topRight, .bottomRight], radius: 10.0)
  }
  override func awakeFromNib() {
    let tapDeleteButtonView = UITapGestureRecognizer(target: self, action: #selector(tapDelete))
    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.addGestureRecognizer(longPressGesture)
    self.addGestureRecognizer(tapDeleteButtonView)
  }

  @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizer.State.began {
      Vibration.success.vibrate()
      delegate?.showActionSheet(text: textInstance!)
    }
  }

  @objc private func tapDelete() {
    Vibration.success.vibrate()
    delegate?.deleteAlarmText(text: textInstance!)
  }
}
