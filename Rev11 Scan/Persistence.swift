//
//  Persistence.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 1/18/17.
//  Copyright © 2017 Revolution11. All rights reserved.
//

import Foundation

class Persistence {
    
    static let defaults = UserDefaults.standard
    
    class func loadBeacons() -> [iBeaconItem] {
        
        var beacons: [iBeaconItem] = []
        
        if let storedBeacons = UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) {
            
            for beaconData in storedBeacons {
                let beacon = NSKeyedUnarchiver.unarchiveObject(with: (beaconData as! NSData) as Data) as! iBeaconItem
                beacons.append(beacon)
            }
        }
        return beacons
    }
    
}
