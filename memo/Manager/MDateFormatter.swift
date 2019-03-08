//
//  MDateFormatter.swift
//  memo
//
//  Created by MinJun KOO on 08/03/2019.
//  Copyright © 2019 mjkoo. All rights reserved.
//

import Foundation

struct MDateFormatter {
  let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale.init(identifier: Locale.current.languageCode!)
    formatter.amSymbol = "AM"
    formatter.pmSymbol = "PM"
    formatter.dateFormat = "YYYY-MM-dd hh:mm a"
    return formatter
  }()
}
