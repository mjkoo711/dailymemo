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
      title: "한번 탭하여 메모작성",
      subtitle: "화면을 한번 클릭하는 것으로 간단한 메모를 작성해보세요.",
      image: UIImage(named: "StartKitEasyMemo2")
    )
    let memoAlarmItem = WhatsNew.Item(
      title: "두번 탭하여 메모 알림받기",
      subtitle: "작성한 메모를 두 번 클릭하여 알람을 설정해보세요. 인앱 동안에는 울리지 않습니다. (알람권한허용 필수)",
      image: UIImage(named: "StartKitMemoAlarm2")
    )
    let variousThemeItem = WhatsNew.Item(
      title: "다양한 테마",
      subtitle: "프로버전을 구매하여 다양한 색상의 테마를 만나보세요. 테마는 계속 추가될 예정입니다.",
      image: UIImage(named: "StartKitTheme2")
    )
    let quickWidgetItem = WhatsNew.Item(
      title: "빠른 위젯접근",
      subtitle: "위젯으로도 쉽게 메모를 체크하고, 메모를 작성할 수 있습니다.",
      image: UIImage(named: "StartKitWidget2")
    )

    let items = [
      easyMemoItem,
      memoAlarmItem,
      variousThemeItem,
      quickWidgetItem
    ]

    let whatsNew = WhatsNew(
      title: "한번 읽어보세요!",
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
      title: "시작하기",
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
