//
//  String.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 9/6/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import CoreLocation

extension String {

  var isEmptyOrWhitespace: Bool {
    return characters.isEmpty ? true : trimmingCharacters(in: .whitespaces) == ""
  }

  var isNotEmptyOrWhitespace: Bool {
    return !isEmptyOrWhitespace
  }

  func convertToUUID() -> UUID {
    let convertedString = UUID(uuidString: self)
    return convertedString!
  }

  func convertToMajorValue() -> CLBeaconMajorValue {
    let convertedToInt = Int(self)
    let convertedToMajorValue = CLBeaconMajorValue(convertedToInt!)
    return convertedToMajorValue
  }

  func convertToMinorValue() -> CLBeaconMinorValue {
    let convertedToInt = Int(self)
    let convertedToMinorValue = CLBeaconMinorValue(convertedToInt!)
    return convertedToMinorValue
  }

}
