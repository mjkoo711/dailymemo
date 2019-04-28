//
//  WhatsNewAppHandler.swift
//  memo
//
//  Created by MinJun KOO on 24/04/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import WhatsNewKit

class WhatsNewAppHandler {
  var whatsNewViewController: WhatsNewViewController?

  init() {
    let easyMemoItem = WhatsNew.Item(
      title: "Single tap to write memo".localized,
      subtitle: "Write a simple note with a click on the screen.".localized,
      image: UIImage(named: "StartKitEasyMemo2")
    )
    let memoAlarmItem = WhatsNew.Item(
      title: "Double tap to set reminder".localized,
      subtitle: "Double tap the note you have created to set the alarm. Does not ring during in-app. (Alarm permission required)".localized,
      image: UIImage(named: "StartKitMemoAlarm2")
    )
    let variousThemeItem = WhatsNew.Item(
      title: "Various Themes".localized,
      subtitle: "Buy a Pro version to apply a variety of color themes. Themes will continue to be added.".localized,
      image: UIImage(named: "StartKitTheme2")
    )
    let quickWidgetItem = WhatsNew.Item(
      title: "Widget available".localized,
      subtitle: "You can easily check memo and write memo with the widget.".localized,
      image: UIImage(named: "StartKitWidget2")
    )

    let items = [
      easyMemoItem,
      memoAlarmItem,
      variousThemeItem,
      quickWidgetItem
    ]

    let whatsNew = WhatsNew(
      title: "Please read it!".localized,
      items: items
    )

    var configuration = WhatsNewViewController.Configuration()
    configuration.completionButton.backgroundColor = Color.Blue
    configuration.apply(animation: .slideUp)
    configuration.itemsView.autoTintImage = false
    configuration.itemsView.subtitleColor = Color.Gray
    configuration.itemsView.subtitleFont = .systemFont(ofSize: 14, weight: .regular)
    configuration.itemsView.imageSize = .fixed(height: 16)
    configuration.completionButton = WhatsNewViewController.CompletionButton(
      title: "Getting Started".localized,
      action: .custom(action: { (viewController) in
        UserDefaults.standard.saveSettings(value: 0, key: Key.StartKit)
        SettingManager.shared.setStartKitMode(value: 0)
        viewController.dismiss(animated: true, completion: nil)
      }),
      hapticFeedback: .notification(.success)
    )
    whatsNewViewController = WhatsNewViewController(
      whatsNew: whatsNew,
      configuration: configuration
    )
  }

  func showsWhatsNewApp(presentViewController: UIViewController) {
    if let whatsNewViewController = self.whatsNewViewController {
      whatsNewViewController.modalTransitionStyle = .coverVertical
      whatsNewViewController.modalPresentationStyle = .overFullScreen
      presentViewController.present(whatsNewViewController, animated: true)
    }
  }
}
