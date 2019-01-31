//
//  TextInputViewController.swift
//  memo
//
//  Created by MinJun KOO on 27/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol TextInputViewControllerDelegate {
  func reloadCollectionView(date: String)
}

class TextInputViewController: UIViewController {
  @IBOutlet var grayAreaView: UIView!
  @IBOutlet var textInputAreaView: UIView!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!

  @IBOutlet var textField: UITextField!

  var date: String?
  var time: String?

  var delegate: TextInputViewControllerDelegate?

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
    textField.inputAccessoryView = UIView()
    textField.returnKeyType = .done
  }
}

extension TextInputViewController {
  @objc func returnMainViewController() {
    textField.resignFirstResponder()
    if let date = date {
      self.delegate?.reloadCollectionView(date: date)
    }
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}

extension TextInputViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let inputText = textField.text, let date = self.date, let time = self.time {
      let text = Text(string: inputText, createdAt: date + " " + time)
      let textManager = TextManager()
      textManager.recordText(key: date, text: text)
    }
    returnMainViewController()
    return true
  }
}
