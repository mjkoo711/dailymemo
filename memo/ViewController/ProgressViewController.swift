//
//  ProgressViewController.swift
//  memo
//
//  Created by MinJun KOO on 31/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import GradientLoadingBar

class ProgressViewController: UIViewController {
  private let safeAreaGradientLoadingBar = GradientLoadingBar(height: 3.0,
                                                              isRelativeToSafeArea: true)
  override func viewDidLoad() {
    super.viewDidLoad()
    safeAreaGradientLoadingBar.show()
  }

  override func viewWillDisappear(_ animated: Bool) {
    safeAreaGradientLoadingBar.hide()
  }
}
