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

  private var basicStringAttributes: [NSAttributedStringKey: Any] {
    var attribs = [NSAttributedStringKey: Any]()

    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = self.textAlignment
    paragraphStyle.lineBreakMode = self.lineBreakMode
    attribs[.paragraphStyle] = paragraphStyle

    return attribs
  }
}
