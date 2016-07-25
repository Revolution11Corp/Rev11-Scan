//
//  BeaconCloudFactory.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/20/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

class BeaconDetailsCloudFactory: BeaconContentFactory {

  func contentForBeaconID(beaconID: BeaconID, completion: (content: AnyObject) -> ()) {

    let beaconDetailRequest = ESTRequestGetBeaconsDetails(beacons: [CLBeacon], andFields: ESTBeaconDetailsFields.FieldName)

//    let beaconDetailsRequest = ESTRequestBeaconDetails(
//      proximityUUID: beaconID.proximityUUID, major: beaconID.major, minor: beaconID.minor)

    beaconDetailsRequest.sendRequestWithCompletion { (beaconDetails, error) in
      if let beaconDetails = beaconDetails {
        completion(content: BeaconDetails(
          beaconName: beaconDetails.name ?? "\(beaconID.major):\(beaconID.minor)",
          beaconColor: beaconDetails.color))
      } else {
        NSLog("Couldn't fetch data from Estimote Cloud for beacon \(beaconID), will use default values instead. Double-check if the app ID and app token provided in the AppDelegate are correct, and if the beacon with such ID is assigned to your Estimote Account. The error was: \(error)")
        completion(content: BeaconDetails(
          beaconName: "beacon",
          beaconColor: .Unknown))
      }
    }
  }

}

protocol BeaconContentFactory {
  func contentForBeaconID(beaconID: BeaconID, completion: (content: AnyObject) -> ())
}