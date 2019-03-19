//
//  Vibration.swift
//  memo
//
//  Created by MinJun KOO on 05/02/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox

enum Vibration {
  case error
  case success
  case warning
  case light
  case medium
  case heavy
  case selection
  case oldSchool

  func vibrate() {
    if let vibrate = SettingManager.shared.vibrate, vibrate == .off {
      return
    }
    
    switch self {
    case .error:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.error)

    case .success:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.success)

    case .warning:
      let generator = UINotificationFeedbackGenerator()
      generator.notificationOccurred(.warning)

    case .light:
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.impactOccurred()

    case .medium:
      let generator = UIImpactFeedbackGenerator(style: .medium)
      generator.impactOccurred()

    case .heavy:
      let generator = UIImpactFeedbackGenerator(style: .heavy)
      generator.impactOccurred()

    case .selection:
      let generator = UISelectionFeedbackGenerator()
      generator.selectionChanged()

    case .oldSchool:
      AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }

  }

}
