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

//class iBeaconItem: NSObject, NSCoding {
class iBeaconItem: NSObject {
    
    private let kCreatedBy                      = "z_createdBy"
    private let kModifiedBy                     = "z_modifiedBy"
    private let kModifiedOn                     = "z_modifiedOn"
    private let kCreatedOn                      = "z_createdOn"
    private let kName                           = "name"
    private let kImageURL                       = "ImageURL"
    private let kActionURL                      = "ActionURL"
    private let kBeaconName                     = "BeaconName"
    private let kMajor                          = "Major"
    private let kMinor                          = "Minor"
    private let kType                           = "type"
    private let kActionURLName                  = "actionURLName"
    private let kActionType                     = "actionType"
    private let kMapURL                         = "mapURL"
    private let kColor                          = "color"
    private let kUUID                           = "UUID"
    private let kIDVend                         = "ID_VEND"
    private let kIDOwn                          = "ID_OWN"
    private let kLatitude                       = "lat"
    private let kLongitude                      = "lon"
    private let kStreetAddress                  = "address"
    private let kCity                           = "city"
    private let kState                          = "state"
    private let kZipcode                        = "zip"
    private let kDocumentOneURL                 = "document1_URL"
    private let kDocumentOneName                = "document1Name"
    private let kTelemetryURLOne                = "telemetryURL_1"
    private let kTelemetryURLTwo                = "telemetryURL_2"
    private let kTelemetryURLThree              = "telemetryURL_3"
    private let kOwnerLogoURL                   = "ownerLogoURL"
    private let kRouteURL                       = "routeURL"
    
    private let kRecordID                       = "recordId"
    private let kModID                          = "modId"
    
    
    var createdBy: String!
    var modifiedBy: String!
    var modifiedOn: String!
    var createdOn: String!
    var name: String!
    var imageURL: String!
    var actionURL: String!
    var beaconName: String!
    var major: CLBeaconMajorValue!
    var minor: CLBeaconMinorValue!
    var type: String!
    var actionURLName: String!
    var mapURL: String!
    var color: String!
    var UUID: UUID!
    var IDVend: String!
    var IDOwn: String!
    var latitude: String!
    var longitude: String!
    var streetAddress: String!
    var city: String!
    var state: String!
    var zipcode: String!
    var documentOneURL: String!
    var documentOneName: String!
    var telemetryOneURL: String!
    var telemetryTwoURL: String!
    var telemetryThreeURL: String!
    var ownerLogoURL: String!
    var routeURL: String!
    
    var recordID: String!
    var modID: String!
    
    @objc dynamic var lastSeenBeacon: CLBeacon?
    
    init(data: [String : Any]) {
        createdBy           = data[kCreatedBy] as? String ?? ""
        modifiedBy          = data[kModifiedBy] as? String ?? ""
        modifiedOn          = data[kModifiedOn] as? String ?? ""
        createdOn           = data[kCreatedOn] as? String ?? ""
        name                = data[kName] as? String ?? ""
        imageURL            = data[kImageURL] as? String ?? ""
        actionURL           = data[kActionURL] as? String ?? ""
        beaconName          = data[kBeaconName] as? String ?? ""
        major               = (data[kMajor] as! String).convertToMajorValue()
        minor               = (data[kMinor] as! String).convertToMinorValue()
        type                = data[kType] as? String ?? ""
        actionURLName       = data[kActionURLName] as? String ?? ""
        mapURL              = data[kMapURL] as? String ?? ""
        color               = data[kColor] as? String ?? ""
        UUID                = (data[kUUID] as! String).convertToUUID()
        IDVend              = data[kIDVend] as? String ?? ""
        IDOwn               = data[kIDOwn] as? String ?? ""
        latitude            = data[kLatitude] as? String ?? ""
        longitude           = data[kLongitude] as? String ?? ""
        streetAddress       = data[kStreetAddress] as? String ?? ""
        city                = data[kCity] as? String ?? ""
        state               = data[kState] as? String ?? ""
        zipcode             = data[kZipcode] as? String ?? ""
        documentOneURL      = data[kDocumentOneURL] as? String ?? ""
        documentOneName     = data[kDocumentOneName] as? String ?? ""
        telemetryOneURL     = data[kTelemetryURLOne] as? String ?? ""
        telemetryTwoURL     = data[kTelemetryURLTwo] as? String ?? ""
        telemetryThreeURL   = data[kTelemetryURLThree] as? String ?? ""
        ownerLogoURL        = data[kOwnerLogoURL] as? String ?? ""
        routeURL            = data[kRouteURL] as? String ?? ""
    }
}

//MARK: NSCoding
//    required init?(coder aDecoder: NSCoder) {
//        if let aName = aDecoder.decodeObject(forKey: BeaconProperties.nameKey) as? String {
//            name = aName
//        }
//        else {
//            name = ""
//        }
//        if let aUUID = aDecoder.decodeObject(forKey: BeaconProperties.uuidKey) as? UUID {
//            uuid = aUUID
//        }
//        else {
//            uuid = UUID()
//        }
//        majorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.majorKey))
//        minorValue = UInt16(aDecoder.decodeInteger(forKey: BeaconProperties.minorKey))
//
//        if let aActionURL = aDecoder.decodeObject(forKey: BeaconProperties.actionURLKey) as? String {
//            actionURL = aActionURL
//        } else {
//            actionURL = ""
//        }
//
//        if let aActionURLName = aDecoder.decodeObject(forKey: BeaconProperties.actionURLNameKey) as? String {
//            actionURLName = aActionURLName
//        } else {
//            actionURLName = ""
//        }
//
//        if let aActionType = aDecoder.decodeObject(forKey: BeaconProperties.actionType) as? String {
//            actionType = aActionType
//        } else {
//            actionType = ""
//        }
//
//        if let aType = aDecoder.decodeObject(forKey: BeaconProperties.typeKey) as? String {
//            type = aType
//        } else {
//            type = ""
//        }
//
//        if let aItemImage = aDecoder.decodeObject(forKey: BeaconProperties.itemImageKey) as? UIImage {
//            itemImage = aItemImage
//        } else {
//            itemImage = UIImage()
//        }
//
//        if let aMapURL = aDecoder.decodeObject(forKey: BeaconProperties.mapURL) as? String {
//            mapURL = aMapURL
//        } else {
//            mapURL = ""
//        }
//
//        if let aColor = aDecoder.decodeObject(forKey: BeaconProperties.colorKey) as? UIColor {
//            color = aColor
//        } else {
//            color = UIColor()
//        }
//
//        if let aBackgroundColor = aDecoder.decodeObject(forKey: BeaconProperties.backgroundColorKey) as? UIColor {
//            backgroundColor = aBackgroundColor
//        } else {
//            backgroundColor = UIColor()
//        }
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: BeaconProperties.nameKey)
//        aCoder.encode(uuid, forKey: BeaconProperties.uuidKey)
//        aCoder.encode(Int(majorValue), forKey: BeaconProperties.majorKey)
//        aCoder.encode(Int(minorValue), forKey: BeaconProperties.minorKey)
//        aCoder.encode(actionURL, forKey: BeaconProperties.actionURLKey)
//        aCoder.encode(actionURLName, forKey: BeaconProperties.actionURLNameKey)
//        aCoder.encode(actionType, forKey: BeaconProperties.actionType)
//        aCoder.encode(type, forKey: BeaconProperties.typeKey)
//        aCoder.encode(itemImage, forKey: BeaconProperties.itemImageKey)
//        aCoder.encode(mapURL, forKey: BeaconProperties.mapURL)
//        aCoder.encode(color, forKey: BeaconProperties.colorKey)
//        aCoder.encode(backgroundColor, forKey: BeaconProperties.backgroundColorKey)
//    }
//
//}
//
func ==(item: iBeaconItem, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.UUID.uuidString)
        && (Int(truncating: beacon.major) == Int(item.major))
        && (Int(truncating: beacon.minor) == Int(item.minor)))
}

