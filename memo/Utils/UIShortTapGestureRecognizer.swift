//
//  UIShortTapGestureRecognizer.swift
//  memo
//
//  Created by MinJun KOO on 15/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesBegan(touches, with: event)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1_100_000)) {
      if self.state != UIGestureRecognizer.State.recognized {
        self.state = UIGestureRecognizer.State.failed
      }
    }
  }
}
