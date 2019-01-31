//
//  TextCollectionViewCell.swift
//  memo
//
//  Created by MinJun KOO on 31/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class TextCollectionViewCell: UICollectionViewCell {
  @IBOutlet var descriptionLabel: UILabel!
  @IBOutlet var widthConstraint: NSLayoutConstraint!

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.translatesAutoresizingMaskIntoConstraints = false
    let leftConstraint = contentView.leftAnchor.constraint(equalTo: leftAnchor)
    let rightConstraint = contentView.rightAnchor.constraint(equalTo: rightAnchor)
    let topConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
    let bottomConstraint = contentView.bottomAnchor.constraint(equalTo: bottomAnchor)

    NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCell))
    self.addGestureRecognizer(tapGesture)
  }

  @objc func handleCell() {
    print("KOO")
  }

}
