//
//  TextInputViewController.swift
//  memo
//
//  Created by MinJun KOO on 27/01/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol TextInputViewControllerDelegate {
  func reloadCollectionViewAndCalendarView(date: String)
}

class TextInputViewController: UIViewController {
  @IBOutlet var grayAreaView: UIView!
  @IBOutlet var textField: UITextField!

  var date: String?
  var time: String?

  var delegate: TextInputViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    textField.delegate = self

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    grayAreaView.addGestureRecognizer(tapGesture)
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
      self.delegate?.reloadCollectionViewAndCalendarView(date: date)
    }
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}

extension TextInputViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let inputText = textField.text, !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let date = self.date, let time = self.time {
      let text = Text(string: inputText, date: date, time: time)
      let textManager = TextManager()
      textManager.recordText(date: date, time: time, text: text)
    }
    returnMainViewController()
    return true
  }
}
