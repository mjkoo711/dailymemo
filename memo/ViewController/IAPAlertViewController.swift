//
//  IAPAlertViewController.swift
//  memo
//
//  Created by MinJun KOO on 02/04/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import UIKit
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
    Vibration.medium.vibrate()
    self.dismiss(animated: true, completion: nil)
  }

  private func loadStorekitInfo() {
    SwiftyStoreKit.retrieveProductsInfo(["com.mjkoo.memo.blancoPro"]) { result in
      if let product = result.retrievedProducts.first {
        let priceString = product.localizedPrice!
        self.purchaseButton.setTitle("Purchase".localized + " - " + "\(priceString)", for: .normal)
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
    Vibration.medium.vibrate()
    let progressViewController = ProgressViewController()
    progressViewController.modalTransitionStyle = .crossDissolve
    progressViewController.modalPresentationStyle = .overFullScreen
    present(progressViewController, animated: true, completion: nil)
    SwiftyStoreKit.restorePurchases(atomically: true) { results in
      if results.restoreFailedPurchases.count > 0 {
        let alertViewController = UIAlertController(title: "Notice".localized, message: "\(results.restoreFailedPurchases)", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
          self.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Restore Failed: \(results.restoreFailedPurchases)")
      }
      else if results.restoredPurchases.count > 0 {
        SettingManager.shared.setPurchaseMode(value: 1)
        UserDefaults.standard.saveSettings(value: 1, key: Key.PurchaseCheckKey)
        self.delegate?.removeBanner()

        let alertViewController = UIAlertController(title: "Notice".localized, message: "Your purchase history has been restored.".localized, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
          self.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Restore Success: \(results.restoredPurchases)")
      }
      else {
        let alertViewController = UIAlertController(title: "Notice".localized, message: "There is no purchase history.".localized, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
          progressViewController.dismiss(animated: true, completion: nil)
          self.dismiss(animated: true, completion: nil)
        }))
        progressViewController.present(alertViewController, animated: true, completion: nil)
        print("Nothing to Restore")
      }
    }
  }

  @IBAction private func purchaseTapped() {
    Vibration.medium.vibrate()
    self.purchase()
  }

  private func setTextLabel() {
    subTitleLabel.text = "Try more features!".localized
    titleLabel.text = "Blanco Pro"
    adRemoveTitleLabel.text = "Remove Ads".localized
    adRemoveDesciptionLabel.text = "Experience cleaner screens with no ads removed.".localized // "광고가 제거된 더 깔끔한 화면을 경험하세요."
    themeTitleLabel.text = "Various Themes".localized
    themeDescriptionLabel.text = "The new theme will continue to be updated, including the existing Dark Mode.".localized
    backupTitleLabel.text = "Backup / Restore".localized
    backupDescriptionLabel.text = "You can back up & restore memo recorded.".localized
    restoreButtonLabel.text = "Restore Your Purchase".localized
    purchaseButton.setTitle("Purchase".localized, for: .normal)
  }

  private func purchase() {
    let progressViewController = ProgressViewController()
    progressViewController.modalTransitionStyle = .crossDissolve
    progressViewController.modalPresentationStyle = .overFullScreen
    present(progressViewController, animated: true, completion: nil)

    SwiftyStoreKit.purchaseProduct("com.mjkoo.memo.blancoPro", quantity: 1, atomically: true) { result in
      switch result {
      case .success(let purchase):
        UserDefaults.standard.saveSettings(value: 1, key: Key.PurchaseCheckKey)
        SettingManager.shared.setPurchaseMode(value: 1)
        self.delegate?.removeBanner()
        progressViewController.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
        print("Purchase Success: \(purchase.productId)")
      case .error(let error):
        switch error.code {
        case .unknown: print("Unknown error. Please contact support")
        case .clientInvalid: print("Not allowed to make the payment")
        case .paymentCancelled:
          progressViewController.dismiss(animated: true, completion: nil)
          break
        case .paymentInvalid: print("The purchase identifier was invalid")
        case .paymentNotAllowed: print("The device is not allowed to make the payment")
        case .storeProductNotAvailable: print("The product is not available in the current storefront")
        case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
        case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
        case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
        default: print((error as NSError).localizedDescription)
        progressViewController.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
}
