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

  var date: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    textField.delegate = self

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    grayAreaView.addGestureRecognizer(tapGesture)

    print(self.date ?? "")
  }

  override func viewWillAppear(_ animated: Bool) {
    settingKeyboard()
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

extension TextInputViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    self.dismiss(animated: false, completion: nil)
    return true
  }
}
