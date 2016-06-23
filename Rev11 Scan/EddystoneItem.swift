//
//  EddystoneItem.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

//import UIKit
//import Foundation
//import CoreLocation
//
//class EddystoneItem: NSObject, NSCoding {
//
//  let name: String
//  let namespace: String //NSUUID??
//  let instance: String //CLBeaconMajorValue
//  let url: String
//  dynamic var lastSeenBeacon: CLBeacon?
//
//  init(name: String, namespace: String, instance: String, url: String) {
//    self.name = name
//    self.namespace = namespace
//    self.instance = instance
//    self.url = url
//  }
//
//  // MARK: NSCoding
//  required init?(coder aDecoder: NSCoder) {
//    if let aName = aDecoder.decodeObjectForKey(BeaconProperties.nameKey) as? String {
//      name = aName
//    }
//    else {
//      name = ""
//    }
//    if let aNamespace = aDecoder.decodeObjectForKey(BeaconProperties.namespaceKey) as? String {
//      namespace = aNamespace
//    }
//    else {
////      namespace = NSUUID()  - Not sure what to do here
//    }
//    // Do I need this UInt16 conversion? I think so, because it's for Decoder. Currenty they are strings, so cant' converto to UInt16. Might not be the way to go.
//    instance = UInt16(aDecoder.decodeIntegerForKey(BeaconProperties.majorKey))
//    url = UInt16(aDecoder.decodeIntegerForKey(BeaconProperties.minorKey))
//  }
//
//  func encodeWithCoder(aCoder: NSCoder) {
//    aCoder.encodeObject(name, forKey: BeaconProperties.nameKey)
//    aCoder.encodeObject(uuid, forKey: BeaconProperties.uuidKey)
//    aCoder.encodeInteger(Int(majorValue), forKey: BeaconProperties.majorKey)
//    aCoder.encodeInteger(Int(minorValue), forKey: BeaconProperties.minorKey)
//  }
//
//}

