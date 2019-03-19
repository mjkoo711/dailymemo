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
  @IBOutlet var repeatSegmentedControl: UISegmentedControl!

  var date: String?
  var time: String?
  var day: String?

  var delegate: TextInputViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setTheme()
    textField.delegate = self

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    grayAreaView.addGestureRecognizer(tapGesture)
  }

  override func viewWillAppear(_ animated: Bool) {
    settingKeyboard()
  }

  private func setTheme() {
    if let theme = SettingManager.shared.theme {
      if theme == .blackRed || theme == .whiteRed {
        repeatSegmentedControl.tintColor = Color.LightRed
      } else if theme == .blackBlue || theme == .whiteBlue {
        repeatSegmentedControl.tintColor = Color.Blue
      }
    }
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
    if let inputText = textField.text, !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let date = self.date, let time = self.time, let day = self.day {
      switch repeatSegmentedControl.selectedSegmentIndex {
      case RepeatMode.Once.rawValue:
        let text = Text(string: inputText, date: date, time: time, day: day, repeatMode: .Once)
        FMDBManager.shared.insertText(text: text)
      case RepeatMode.Daily.rawValue:
        let text = Text(string: inputText, date: date, time: time, day: day, repeatMode: .Daily)
        FMDBManager.shared.insertText(text: text)
      case RepeatMode.Weekly.rawValue:
        let text = Text(string: inputText, date: date, time: time, day: day, repeatMode: .Weekly)
        FMDBManager.shared.insertText(text: text)
      case RepeatMode.Monthly.rawValue:
        let text = Text(string: inputText, date: date, time: time, day: day, repeatMode: .Monthly)
        FMDBManager.shared.insertText(text: text)
      default:
        return true
      }
    }
    returnMainViewController()
    return true
  }

  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    Vibration.heavy.vibrate()
    return true
  }
}
