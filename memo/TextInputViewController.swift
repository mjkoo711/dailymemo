//
//  TextInputViewController.swift
//  memo
//
//  Created by MinJun KOO on 27/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class TextInputViewController: UIViewController {
  @IBOutlet var grayAreaView: UIView!
  @IBOutlet var textInputAreaView: UIView!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!

  @IBOutlet var textField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
    settingKeyboard()

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    grayAreaView.addGestureRecognizer(tapGesture)
  }

  private func settingKeyboard() {
    textField.becomeFirstResponder()
    textField.keyboardToolbar.isHidden = true
    textField.inputAccessoryView = UIView()
    textField.keyboardDistanceFromTextField = 8;
    textField.returnKeyType = .done
  }
}

extension TextInputViewController {
  @objc func returnMainViewController() {
    textField.resignFirstResponder()
    self.dismiss(animated: false, completion: nil)
  }
}
