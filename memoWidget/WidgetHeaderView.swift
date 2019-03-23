//
//  WidgetHeaderView.swift
//  memoWidget
//
//  Created by MinJun KOO on 23/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol WidgetCollectionReusableViewDelegate {
  func goApp()
}

class WidgetCollectionReusableView: UICollectionReusableView {
  var delegate: WidgetCollectionReusableViewDelegate?

  override func awakeFromNib() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goApp))
    self.addGestureRecognizer(tapGesture)
  }

  @objc private func goApp() {
    Vibration.success.vibrate()
    delegate?.goApp()
  }
}
