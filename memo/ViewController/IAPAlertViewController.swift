//
//  IAPAlertViewController.swift
//  memo
//
//  Created by MinJun KOO on 02/04/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import GradientLoadingBar

class IAPAlertViewController: UIViewController {
  private let safeAreaGradientLoadingBar = GradientLoadingBar(height: 3.0,
                                                              isRelativeToSafeArea: true)
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  private func showLoadingBar() {
    safeAreaGradientLoadingBar.show()
  }

  private func hideLoadingBar() {
    safeAreaGradientLoadingBar.hide()
  }
}

// TODO: pod 'WhatsNew' 를 활용하여 테마, 백업복원, 광고제거 기능 있다고 설명해주고 버튼에 action 달아서 구매할 수 있게 하기
