//
//  SettingViewController.swift
//  memo
//
//  Created by MinJun KOO on 05/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  @IBOutlet var closeButtonView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    closeButtonView.addGestureRecognizer(tapGesture)
  }
}

extension SettingViewController {
  @objc func returnMainViewController() {
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}
