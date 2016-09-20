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
  static let actionURLKey = "actionURL"
  static let itemImageKey = "itemImage"
  static let colorKey = "color"

  static let storedBeaconArrayKey = "storedBeaconsArray"

  // Eddystone Properties
  static let namespaceKey = "namespace"
  static let instanceKey = "instance"
  static let urlKey = "url"
}


struct Colors {
  static let white    = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
  static let darkGrey = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
  static let red      = UIColor(red: 255.0/255.0, green: 157.0/255.0, blue: 169.0/255.0, alpha: 1.0)
  static let yellow   = UIColor(red: 255.0/255.0, green: 249.0/255.0, blue: 176.0/255.0, alpha: 1.0)
  static let green    = UIColor(red: 184.0/255.0, green: 233.0/255.0, blue: 134.0/255.0, alpha: 1.0)
  static let blue     = UIColor(red: 27.0/255.0, green: 117.0/255.0, blue: 187.0/255.0, alpha: 1.0)
}

struct Images {
  static let qrTabBlue          = "qr-tabbar-blue"
  static let eddystoneTabBlue   = "eddystone-tabbar-blue"
  static let beaconTabBlue      = "beacon-tabbar-blue"
  static let estimoteTabBlue    = "estimote-tabbar-blue"
}

struct Constants {
  static let defaults = UserDefaults.standard
}

struct Keys {
  static let isFromFileMaker  = "isFromFileMaker"
  static let lastSeenEstimote = "lastSeenEstimote"
  static let lastSeenBeacon   = "lastSeenBeacon"
  static let suiteName        = "group.rev11scan"
  static let spreadsheetFile  = "spreadsheetFileAsData"
  static let beaconRegionUUID = "B9407F30-F5F8-466E-AFF9-25556B57FE6D"
  static let estimoteAppID    = "rev11scan-nxl"
  static let estimoteAppToken = "d55de5f606394c3cb74f007ec8bd1244"
}

struct Cells {
  static let estimoteCell   = "EstimoteCell"
  static let eddystoneCell  = "EddystoneCell"
  static let beaconCell     = "BeaconCell"


}
