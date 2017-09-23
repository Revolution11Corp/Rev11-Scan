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
    let uuid: UUID
    let majorValue: CLBeaconMajorValue
    let minorValue: CLBeaconMinorValue
    let actionURL: String
    let actionURLName: String
    let actionType: String
    let type: String
    let itemImage: UIImage
    let mapURL: String
    let color: UIColor
    
    var backgroundColor: UIColor?
    
    
    @objc dynamic var lastSeenBeacon: CLBeacon?
    
    init(name: String, uuid: UUID, majorValue: CLBeaconMajorValue?, minorValue: CLBeaconMinorValue?, itemImage: UIImage, actionURL: String, actionURLName: String, actionType: String, type: String, mapURL: String, color: UIColor, backgroundColor: UIColor) {
        self.name = name
        self.uuid = uuid
        self.majorValue = majorValue!
        self.minorValue = minorValue!
        self.itemImage = itemImage
        self.actionURL = actionURL
        self.actionURLName = actionURLName
        self.actionType = actionType
        self.type = type
        self.mapURL = mapURL
        self.color = color
        
        self.backgroundColor = Colors.white
    }
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        if let aName = aDecoder.decodeObject(forKey: BeaconProperties.nameKey) as? String {
            name = aName
        }
        else {
            name = ""
        }
        if let aUUID = aDecoder.decodeObject(forKey: BeaconProperties.uuidKey) as? UUID {
            uuid = aUUID
        }
        else {
            uuid = UUID()
        }
        majorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.majorKey))
        minorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.minorKey))
        
        if let aActionURL = aDecoder.decodeObject(forKey: BeaconProperties.actionURLKey) as? String {
            actionURL = aActionURL
        } else {
            actionURL = ""
        }
        
        if let aActionURLName = aDecoder.decodeObject(forKey: BeaconProperties.actionURLNameKey) as? String {
            actionURLName = aActionURLName
        } else {
            actionURLName = ""
        }
        
        if let aActionType = aDecoder.decodeObject(forKey: BeaconProperties.actionType) as? String {
            actionType = aActionType
        } else {
            actionType = ""
        }
        
        if let aType = aDecoder.decodeObject(forKey: BeaconProperties.typeKey) as? String {
            type = aType
        } else {
            type = ""
        }
        
        if let aItemImage = aDecoder.decodeObject(forKey: BeaconProperties.itemImageKey) as? UIImage {
            itemImage = aItemImage
        } else {
            itemImage = UIImage()
        }
        
        if let aMapURL = aDecoder.decodeObject(forKey: BeaconProperties.mapURL) as? String {
            mapURL = aMapURL
        } else {
            mapURL = ""
        }
        
        if let aColor = aDecoder.decodeObject(forKey: BeaconProperties.colorKey) as? UIColor {
            color = aColor
        } else {
            color = UIColor()
        }
        
        if let aBackgroundColor = aDecoder.decodeObject(forKey: BeaconProperties.backgroundColorKey) as? UIColor {
            backgroundColor = aBackgroundColor
        } else {
            backgroundColor = UIColor()
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: BeaconProperties.nameKey)
        aCoder.encode(uuid, forKey: BeaconProperties.uuidKey)
        aCoder.encode(Int(majorValue), forKey: BeaconProperties.majorKey)
        aCoder.encode(Int(minorValue), forKey: BeaconProperties.minorKey)
        aCoder.encode(actionURL, forKey: BeaconProperties.actionURLKey)
        aCoder.encode(actionURLName, forKey: BeaconProperties.actionURLNameKey)
        aCoder.encode(actionType, forKey: BeaconProperties.actionType)
        aCoder.encode(type, forKey: BeaconProperties.typeKey)
        aCoder.encode(itemImage, forKey: BeaconProperties.itemImageKey)
        aCoder.encode(mapURL, forKey: BeaconProperties.mapURL)
        aCoder.encode(color, forKey: BeaconProperties.colorKey)
        aCoder.encode(backgroundColor, forKey: BeaconProperties.backgroundColorKey)
    }
    
}

func ==(item: iBeaconItem, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.uuid.uuidString)
        && (Int(beacon.major) == Int(item.majorValue))
        && (Int(beacon.minor) == Int(item.minorValue)))
}

