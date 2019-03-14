//
//  UIVIewExtensions.swift
//  memo
//
//  Created by MinJun KOO on 15/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
