//
//  UILabelExtension.swift
//  memo
//
//  Created by MinJun KOO on 02/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {

  /// Will auto resize the contained text to a font size which fits the frames bounds.
  /// Uses the pre-set font to dynamically determine the proper sizing
  func fitTextToBounds() {
    guard let text = text, let currentFont = font else { return }

    let bestFittingFont = UIFont.bestFittingFont(for: text, in: bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
    font = bestFittingFont
  }

  private var basicStringAttributes: [NSAttributedString.Key: Any] {
    var attribs = [NSAttributedString.Key: Any]()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = self.textAlignment
    paragraphStyle.lineBreakMode = self.lineBreakMode
    attribs[.paragraphStyle] = paragraphStyle

    return attribs
  }

  func blink() {
    self.alpha = 0.0
    UITextView.animate(withDuration: 0.7, delay: 0.0, options: [.curveLinear, .curveEaseInOut], animations: {
      self.alpha = 1.0
    }, completion: nil)
  }
}
