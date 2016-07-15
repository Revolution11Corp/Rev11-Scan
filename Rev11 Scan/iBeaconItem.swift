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


class iBeaconItem: NSObject, NSCoding {

  let name: String
  let uuid: NSUUID
  let majorValue: CLBeaconMajorValue
  let minorValue: CLBeaconMinorValue

  var color: UIColor?

  dynamic var lastSeenBeacon: CLBeacon?

  init(name: String, uuid: NSUUID, majorValue: CLBeaconMajorValue, minorValue: CLBeaconMinorValue, color: UIColor) {
    self.name = name
    self.uuid = uuid
    self.majorValue = majorValue
    self.minorValue = minorValue
    self.color = Colors.white
  }

  // MARK: NSCoding
  required init?(coder aDecoder: NSCoder) {
    if let aName = aDecoder.decodeObjectForKey(BeaconProperties.nameKey) as? String {
      name = aName
    }
    else {
      name = ""
    }
    if let aUUID = aDecoder.decodeObjectForKey(BeaconProperties.uuidKey) as? NSUUID {
      uuid = aUUID
    }
    else {
      uuid = NSUUID()
    }
    majorValue = UInt16(aDecoder.decodeIntegerForKey(BeaconProperties.majorKey))
    minorValue = UInt16(aDecoder.decodeIntegerForKey(BeaconProperties.minorKey))
  }

  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: BeaconProperties.nameKey)
    aCoder.encodeObject(uuid, forKey: BeaconProperties.uuidKey)
    aCoder.encodeInteger(Int(majorValue), forKey: BeaconProperties.majorKey)
    aCoder.encodeInteger(Int(minorValue), forKey: BeaconProperties.minorKey)
  }

}

func ==(item: iBeaconItem, beacon: CLBeacon) -> Bool {
  return ((beacon.proximityUUID.UUIDString == item.uuid.UUIDString)
    && (Int(beacon.major) == Int(item.majorValue))
    && (Int(beacon.minor) == Int(item.minorValue)))
}

