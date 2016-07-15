//
//  Constants.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

struct BeaconProperties {
  static let nameKey = "name"

  // iBeacon Properties
  static let uuidKey = "uuid"
  static let majorKey = "major"
  static let minorKey = "minor"

  // Eddystone Properties
  static let namespaceKey = "namespace"
  static let instanceKey = "instance"
  static let urlKey = "url"
}


struct Colors {
  static let white    = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
  static let red      = UIColor(red: 255.0/255.0, green: 157.0/255.0, blue: 169.0/255.0, alpha: 1.0)
  static let yellow   = UIColor(red: 255.0/255.0, green: 249.0/255.0, blue: 176.0/255.0, alpha: 1.0)
  static let green    = UIColor(red: 184.0/255.0, green: 233.0/255.0, blue: 134.0/255.0, alpha: 1.0)
}
