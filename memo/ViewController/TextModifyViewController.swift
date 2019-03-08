//
//  TextModifyViewController.swift
//  memo
//
//  Created by MinJun KOO on 05/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

protocol TextModifyViewControllerDelegate {
  func reloadCollectionViewAndCalendarView(date: String)
}

class TextModifyViewController: UIViewController {
  @IBOutlet var grayAreaView: UIView!
  @IBOutlet var textField: UITextField!

  var date: String?
  var time: String?

  var existText: Text?

  var delegate: TextModifyViewControllerDelegate?

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
    textField.text = existText?.string
    textField.inputAccessoryView = UIView()
    textField.returnKeyType = .done
  }
}

extension TextModifyViewController {
  @objc func returnMainViewController() {
    textField.resignFirstResponder()
    if let date = date {
      self.delegate?.reloadCollectionViewAndCalendarView(date: date)
    }
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}

extension TextModifyViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if let inputText = textField.text, !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      let textManager = OnceTextManager()

      if let exist = self.existText {
        exist.string = inputText
        textManager.recordText(date: exist.date, time: exist.time, text: exist)
        if exist.isAlarmSetting {
          AlarmManager().modifyNotification(textSelected: exist, notificationType: .Once)
        }
      }
    }
    returnMainViewController()
    return true
  }
}
