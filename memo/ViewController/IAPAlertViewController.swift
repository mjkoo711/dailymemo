//
//  IAPAlertViewController.swift
//  memo
//
//  Created by MinJun KOO on 02/04/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
import GradientLoadingBar
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_ButtonThemer
import MaterialComponents.MaterialButtons_ColorThemer
import SwiftyStoreKit

protocol IAPAlertViewControllerDelegate {
  func removeBanner()
}

class IAPAlertViewController: UIViewController {
  @IBOutlet var subTitleLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!

  @IBOutlet var adRemoveTitleLabel: UILabel!
  @IBOutlet var adRemoveDesciptionLabel: UILabel!

  @IBOutlet var themeTitleLabel: UILabel!
  @IBOutlet var themeDescriptionLabel: UILabel!

  @IBOutlet var backupTitleLabel: UILabel!
  @IBOutlet var backupDescriptionLabel: UILabel!

  @IBOutlet var closeImageButtonView: UIImageView!

  @IBOutlet var restoreButtonLabel: UILabel!
  @IBOutlet var purchaseButton: MDCButton!

  var delegate: IAPAlertViewControllerDelegate?
  
  private let safeAreaGradientLoadingBar = GradientLoadingBar(height: 3.0,
                                                              isRelativeToSafeArea: true)
  override func viewDidLoad() {
    super.viewDidLoad()
    setTextLabel()
    loadStorekitInfo()
    let closeTapped = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
    closeImageButtonView.isUserInteractionEnabled = true
    closeImageButtonView.addGestureRecognizer(closeTapped)

    let restorePurchaseTapped = UITapGestureRecognizer(target: self, action: #selector(restorePurchase))
    restoreButtonLabel.isUserInteractionEnabled = true
    restoreButtonLabel.addGestureRecognizer(restorePurchaseTapped)
  }

  @objc private func dismissViewController() {
    Vibration.heavy.vibrate()
    self.dismiss(animated: true, completion: nil)
  }

  private func loadStorekitInfo() {
    SwiftyStoreKit.retrieveProductsInfo(["com.mjkoo.memo.memomentPro"]) { result in
      if let product = result.retrievedProducts.first {
        let priceString = product.localizedPrice!
        self.purchaseButton.setTitle("구매하기" + " - " + "\(priceString)", for: .normal)
        print("Product: \(product.localizedDescription), price: \(priceString)")
      }
      else if let invalidProductId = result.invalidProductIDs.first {
        print("Invalid product identifier: \(invalidProductId)")
      }
      else {
        print("Error: \(result.error)")
      }
    }
  }

  @objc private func restorePurchase() {
    Vibration.heavy.vibrate()
    let progressViewController = ProgressViewController()
    progressViewController.modalTransitionStyle = .crossDissolve
    progressViewController.modalPresentationStyle = .overFullScreen
    present(progressViewController, animated: true, completion: nil)
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      if results.restoreFailedPurchases.count > 0 {
        let alertViewController = UIAlertController(title: "알림", message: "\(results.restoreFailedPurchases)", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Restore Failed: \(results.restoreFailedPurchases)")
      }
      else if results.restoredPurchases.count > 0 {
        SettingManager.shared.setPurchaseMode(value: 1)
        UserDefaults.standard.saveSettings(value: 1, key: Key.PurchaseCheckKey)
        self.delegate?.removeBanner()

        let alertViewController = UIAlertController(title: "알림", message: "구매내역이 복원되었습니다.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Restore Success: \(results.restoredPurchases)")
      }
      else {
        let alertViewController = UIAlertController(title: "알림", message: "구매한 기록이 없습니다.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Nothing to Restore")
      }
    }
  }

  @IBAction private func purchaseTapped() {
    Vibration.heavy.vibrate()
    self.purchase()
  }

  private func setTextLabel() {
    subTitleLabel.text = "더 많은 기능을 사용해보세요!"
    titleLabel.text = "Memoment Pro"
    adRemoveTitleLabel.text = "광고가 제거됩니다."
    adRemoveDesciptionLabel.text = "배너 광고가 제거된 더 깔끔한 화면을 경험하세요."
    themeTitleLabel.text = "더 많은 테마를 사용해보세요."
    themeDescriptionLabel.text = "기존의 다크모드를 포함한 새로운 테마가 계속 업데이트 될 예정입니다."
    backupTitleLabel.text = "데이터 백업/복원이 가능합니다."
    backupDescriptionLabel.text = "저장된 메모를 백업하고 복원할 수 있습니다."
    restoreButtonLabel.text = "구매 복원하기"
    purchaseButton.setTitle("구매하기", for: .normal)
  }

  private func showLoadingBar() {
    safeAreaGradientLoadingBar.show()
  }

  private func hideLoadingBar() {
    safeAreaGradientLoadingBar.hide()
  }

  private func purchase() {
    let progressViewController = ProgressViewController()
    progressViewController.modalTransitionStyle = .crossDissolve
    progressViewController.modalPresentationStyle = .overFullScreen
    present(progressViewController, animated: true, completion: nil)

    SwiftyStoreKit.purchaseProduct("com.mjkoo.memo.memomentPro", quantity: 1, atomically: true) { result in
      switch result {
      case .success(let purchase):
        UserDefaults.standard.saveSettings(value: 1, key: Key.PurchaseCheckKey)
        SettingManager.shared.setPurchaseMode(value: 1)
        self.delegate?.removeBanner()
        print("Purchase Success: \(purchase.productId)")
      case .error(let error):
        switch error.code {
        case .unknown: print("Unknown error. Please contact support")
        case .clientInvalid: print("Not allowed to make the payment")
        case .paymentCancelled: break
        case .paymentInvalid: print("The purchase identifier was invalid")
        case .paymentNotAllowed: print("The device is not allowed to make the payment")
        case .storeProductNotAvailable: print("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
        default: print((error as NSError).localizedDescription)
        }
      }
      progressViewController.dismiss(animated: true, completion: nil)
    }
  }
}
