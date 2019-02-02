//
//  TextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 02/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
  @IBOutlet var descriptionLabel: UILabel!
  
  override func awakeFromNib() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCell))
    self.addGestureRecognizer(tapGesture)
  }

  @objc func handleCell() {
    print("KOO")
  }

}
