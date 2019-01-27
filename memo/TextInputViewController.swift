//
//  TextInputViewController.swift
//  memo
//
//  Created by MinJun KOO on 27/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class TextInputViewController: UIViewController {
  @IBOutlet var grayAreaView: UIView!
  @IBOutlet var textInputAreaView: UIView!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!

  @IBOutlet var textField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}
