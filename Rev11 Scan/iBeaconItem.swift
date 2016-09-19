//
//  iBeaconItem.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

// Add NSCoding after NSObject if you want to persist beacons by coding/decoding them
class iBeaconItem: NSObject {

  let name: String
  let uuid: UUID
  let majorValue: CLBeaconMajorValue
  let minorValue: CLBeaconMinorValue
  let actionURL: String
  let itemImage: UIImage

  var color: UIColor?

  dynamic var lastSeenBeacon: CLBeacon?

  init(name: String, uuid: UUID, majorValue: CLBeaconMajorValue?, minorValue: CLBeaconMinorValue?, itemImage: UIImage, actionURL: String, color: UIColor) {
    self.name = name
    self.uuid = uuid
    self.majorValue = majorValue!
    self.minorValue = minorValue!
    self.itemImage = itemImage
    self.actionURL = actionURL
    self.color = Colors.white
  }

  // MARK: NSCoding
//  required init?(coder aDecoder: NSCoder) {
//    if let aName = aDecoder.decodeObject(forKey: BeaconProperties.nameKey) as? String {
//      name = aName
//    }
//    else {
//      name = ""
//    }
//    if let aUUID = aDecoder.decodeObject(forKey: BeaconProperties.uuidKey) as? UUID {
//      uuid = aUUID
//    }
//    else {
//      uuid = UUID()
//    }
//    majorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.majorKey))
//    minorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.minorKey))
//  }
//
//  func encode(with aCoder: NSCoder) {
//    aCoder.encode(name, forKey: BeaconProperties.nameKey)
//    aCoder.encode(uuid, forKey: BeaconProperties.uuidKey)
//    aCoder.encode(Int(majorValue), forKey: BeaconProperties.majorKey)
//    aCoder.encode(Int(minorValue), forKey: BeaconProperties.minorKey)
//  }

}

func ==(item: iBeaconItem, beacon: CLBeacon) -> Bool {
  return ((beacon.proximityUUID.uuidString == item.uuid.uuidString)
    && (Int(beacon.major) == Int(item.majorValue))
    && (Int(beacon.minor) == Int(item.minorValue)))
}

