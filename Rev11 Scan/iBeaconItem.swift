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
    var actionType: String!
    var actionURLName: String!
    var beaconName: String!
    var major: CLBeaconMajorValue!
    var minor: CLBeaconMinorValue!
    var type: String!
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
        actionType          = data[kActionType] as? String ?? ""
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
        recordID            = data[kRecordID] as? String ?? ""
        modID               = data[kModID] as? String ?? ""
    }

//MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        
        if let aCreatedBy = aDecoder.decodeObject(forKey: kCreatedBy) as? String {
            createdBy = aCreatedBy
        } else {
            createdBy = ""
        }
        
        if let aModifiedBy = aDecoder.decodeObject(forKey: kModifiedBy) as? String {
            modifiedBy = aModifiedBy
        } else {
            modifiedBy = ""
        }
        
        if let aModifiedOn = aDecoder.decodeObject(forKey: kModifiedOn) as? String {
            modifiedOn = aModifiedOn
        } else {
            modifiedOn = ""
        }
        
        if let aCreatedOn = aDecoder.decodeObject(forKey: kCreatedOn) as? String {
            createdOn = aCreatedOn
        } else {
            createdOn = ""
        }
        
        if let aName = aDecoder.decodeObject(forKey: kName) as? String {
            name = aName
        } else {
            name = ""
        }
        
        if let aImageURL = aDecoder.decodeObject(forKey: kImageURL ) as? String {
            imageURL = aImageURL
        } else {
            imageURL = ""
        }
        
        if let aActionURL = aDecoder.decodeObject(forKey: kActionURL) as? String {
            actionURL = aActionURL
        } else {
            actionURL = ""
        }
        
        if let aActionType = aDecoder.decodeObject(forKey: kActionType) as? String {
            actionType = aActionType
        } else {
            actionType = ""
        }

        if let aActionURLName = aDecoder.decodeObject(forKey: kActionURLName) as? String {
            actionURLName = aActionURLName
        } else {
            actionURLName = ""
        }
        
        if let aBeaconName = aDecoder.decodeObject(forKey: kBeaconName) as? String {
            beaconName = aBeaconName
        } else {
            beaconName = ""
        }
        
        major = UInt16(aDecoder.decodeInteger(forKey: kMajor))
        minor = UInt16(aDecoder.decodeInteger(forKey: kMinor))

        if let aType = aDecoder.decodeObject(forKey: kType) as? String {
            type = aType
        } else {
            type = ""
        }

        if let aMapURL = aDecoder.decodeObject(forKey: kMapURL) as? String {
            mapURL = aMapURL
        } else {
            mapURL = ""
        }

        if let aColor = aDecoder.decodeObject(forKey: kColor) as? String {
            color = aColor
        } else {
            color = ""
        }
        
        if let aUUID = aDecoder.decodeObject(forKey: kUUID) as? UUID {
            UUID = aUUID
        } else {
            UUID = nil
        }
        
        if let aIDVend = aDecoder.decodeObject(forKey: kIDVend) as? String {
            IDVend = aIDVend
        } else {
            IDVend = ""
        }
        
        if let aIDOwn = aDecoder.decodeObject(forKey: kIDOwn) as? String {
            IDOwn = aIDOwn
        } else {
            IDOwn = ""
        }
        
        if let aLatitude = aDecoder.decodeObject(forKey: kLatitude) as? String {
            latitude = aLatitude
        } else {
            latitude = ""
        }
        
        if let aLongitude = aDecoder.decodeObject(forKey: kLongitude) as? String {
            longitude = aLongitude
        } else {
            longitude = ""
        }
        
        if let aStreet = aDecoder.decodeObject(forKey: kStreetAddress) as? String {
            streetAddress = aStreet
        } else {
            streetAddress = ""
        }

        if let aCity = aDecoder.decodeObject(forKey: kCity) as? String {
            city = aCity
        } else {
            city = ""
        }
        
        if let aState = aDecoder.decodeObject(forKey: kState) as? String {
            state = aState
        } else {
            state = ""
        }
        
        if let aZipcode = aDecoder.decodeObject(forKey: kZipcode) as? String {
            zipcode = aZipcode
        } else {
            zipcode = ""
        }
        
        if let aDocumentOneURL = aDecoder.decodeObject(forKey: kDocumentOneURL) as? String {
            documentOneURL = aDocumentOneURL
        } else {
            documentOneURL = ""
        }
        
        if let aDocumentOneName = aDecoder.decodeObject(forKey: kDocumentOneName) as? String {
            documentOneName = aDocumentOneName
        } else {
            documentOneName = ""
        }
        
        if let aTelemetryOneURL = aDecoder.decodeObject(forKey: kTelemetryURLOne) as? String {
            telemetryOneURL = aTelemetryOneURL
        } else {
            telemetryOneURL = ""
        }
        
        if let aTelemetryTwoURL = aDecoder.decodeObject(forKey: kTelemetryURLTwo) as? String {
            telemetryTwoURL = aTelemetryTwoURL
        } else {
            telemetryTwoURL = ""
        }
        
        if let aTelemetryThreeURL = aDecoder.decodeObject(forKey: kTelemetryURLThree) as? String {
            telemetryThreeURL = aTelemetryThreeURL
        } else {
            telemetryThreeURL = ""
        }
        
        if let aOwnerLogoURL = aDecoder.decodeObject(forKey: kOwnerLogoURL) as? String {
            ownerLogoURL = aOwnerLogoURL
        } else {
            ownerLogoURL = ""
        }
        
        if let aRouteURL = aDecoder.decodeObject(forKey: kRouteURL) as? String {
            routeURL = aRouteURL
        } else {
            routeURL = ""
        }
        
        if let aRecordID = aDecoder.decodeObject(forKey: kRecordID) as? String {
            recordID = aRecordID
        } else {
            recordID = ""
        }
        
        if let aModID = aDecoder.decodeObject(forKey: kModID) as? String {
            modID = aModID
        } else {
            modID = ""
        }
    }


    func encode(with aCoder: NSCoder) {
        aCoder.encode(createdBy, forKey: kCreatedBy)
        aCoder.encode(modifiedBy, forKey: kModifiedBy)
        aCoder.encode(modifiedOn, forKey: kModifiedOn)
        aCoder.encode(createdOn, forKey: kCreatedOn)
        aCoder.encode(name, forKey: kName)
        aCoder.encode(imageURL, forKey: kImageURL)
        aCoder.encode(actionURL, forKey: kActionURL)
        aCoder.encode(actionURLName, forKey: kActionURLName)
        aCoder.encode(actionType, forKey: kActionType)
        aCoder.encode(beaconName, forKey: kBeaconName)
        aCoder.encode(Int(major), forKey: kMajor)
        aCoder.encode(Int(minor), forKey: kMinor)
        aCoder.encode(type, forKey: kType)
        aCoder.encode(mapURL, forKey: kMapURL)
        aCoder.encode(color, forKey: kColor)
        aCoder.encode(UUID, forKey: kUUID)
        aCoder.encode(IDVend, forKey: kIDVend)
        aCoder.encode(IDOwn, forKey: kIDOwn)
        aCoder.encode(latitude, forKey: kLatitude)
        aCoder.encode(longitude, forKey: kLongitude)
        aCoder.encode(streetAddress, forKey: kStreetAddress)
        aCoder.encode(city, forKey: kCity)
        aCoder.encode(state, forKey: kState)
        aCoder.encode(zipcode, forKey: kZipcode)
        aCoder.encode(documentOneURL, forKey: kDocumentOneURL)
        aCoder.encode(documentOneName, forKey: kDocumentOneName)
        aCoder.encode(telemetryOneURL, forKey: kTelemetryURLOne)
        aCoder.encode(telemetryTwoURL, forKey: kTelemetryURLTwo)
        aCoder.encode(telemetryThreeURL, forKey: kTelemetryURLThree)
        aCoder.encode(ownerLogoURL, forKey: kOwnerLogoURL)
        aCoder.encode(routeURL, forKey: kRouteURL)
        aCoder.encode(recordID, forKey: kRecordID)
        aCoder.encode(modID, forKey: kModID)
    }

}

func ==(item: iBeaconItem, beacon: CLBeacon) -> Bool {
    return ((beacon.proximityUUID.uuidString == item.UUID.uuidString)
        && (Int(truncating: beacon.major) == Int(item.major))
        && (Int(truncating: beacon.minor) == Int(item.minor)))
}

