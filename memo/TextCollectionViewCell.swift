//
//  TextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 02/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol TextCollectionViewCellDelegate {
  func showEditAndRemoveButton(text: Text)
}

class TextCollectionViewCell: UICollectionViewCell {
  var textInstance: Text!
  @IBOutlet var descriptionLabel: UILabel!

  var delegate: TextCollectionViewCellDelegate?
  
  override func awakeFromNib() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCell))
    self.addGestureRecognizer(tapGesture)

    let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    self.addGestureRecognizer(longPressGesture)
  }

  @objc func handleCell() {
    print("KOO")
  }

  @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
    if sender.state == UIGestureRecognizerState.began {
      print("CreatedAt: \(textInstance.createdAt)")
      delegate?.showEditAndRemoveButton(text: textInstance)
    } else if sender.state == UIGestureRecognizerState.ended {
      print("JUN")
    }
  }
}
