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
}

class TextCollectionViewCell: UICollectionViewCell {
  var textInstance: Text?
  @IBOutlet var descriptionLabel: UILabel!

  var delegate: TextCollectionViewCellDelegate?
  
  override func awakeFromNib() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCell))
    self.addGestureRecognizer(tapGesture)

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.addGestureRecognizer(longPressGesture)
  }

  @objc func handleCell() {
    Vibration.medium.vibrate()
    // TODO: 첫번째 클릭시, 두번째 클릭시
  }

  @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizer.State.began {
      Vibration.success.vibrate()
      delegate?.showActionSheet(text: textInstance!)
    }
  }
}
