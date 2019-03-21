//
//  WidgetTextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 03/21/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol WidgetTextCollectionViewCellDelegate {
  func reloadCollectionView(date: String)
}

class WidgetTextCollectionViewCell: UICollectionViewCell {
  var textInstance: Text?
  var currentDate: String?
  var isCompleted: Bool?

  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var checkImage: UIImageView!

  var delegate: WidgetTextCollectionViewCellDelegate?

  override func awakeFromNib() {
    let singleTapGesture = UIShortTapGestureRecognizer(target: self, action: #selector(didPressPartButton))
    singleTapGesture.numberOfTapsRequired = 1
    self.addGestureRecognizer(singleTapGesture)
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
}

