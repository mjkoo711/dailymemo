//
//  SettingViewController.swift
//  memo
//
//  Created by MinJun KOO on 05/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
  // 다크모드, 글자크기(작게중간크게), 글자두께(얇게보통두껍게), 터치onoff, 잠금onoff
  // 백업및복원, 메모모두초기화, 리뷰부탁하기, 문의하기, 프로버전 구매
  let designList = ["어두운 테마", "글자 크기", "글자 두께", "진동", "잠금 설정"]
  let serviceList = ["프로버전 구매", "백업 / 복원", "리뷰 남기기", "문의메일 보내기"]
  @IBOutlet var closeButtonView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(returnMainViewController))
    closeButtonView.addGestureRecognizer(tapGesture)
  }
}

extension SettingViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return designList.count
    } else {
      return serviceList.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCollectionViewCell", for: indexPath) as! SettingCollectionViewCell
    if indexPath.section == 0 {
      cell.settingTitleLabel.text = designList[indexPath.row]
    } else {
      cell.settingTitleLabel.text = serviceList[indexPath.row]
      cell.switchLabel.isHidden = true
    }
    return cell
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
}

extension SettingViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: UIScreen.main.bounds.width, height: 35.0)
  }
}

extension SettingViewController {
  @objc func returnMainViewController() {
    performSegue(withIdentifier: "unwindMainVC", sender: self)
  }
}
