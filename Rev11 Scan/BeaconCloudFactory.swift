//
//  BeaconCloudFactory.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/20/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

class BeaconDetailsCloudFactory {

  func contentForBeacons(beacons: [CLBeacon], completion: (content: AnyObject) -> ()) {

    let request = ESTRequestGetBeaconsDetails(beacons: beacons, andFields: ESTBeaconDetailsFields.FieldName)

    request.sendRequestWithCompletion { (beaconDetails, error) in

      let item = beaconDetails![0]

      // iterate through beaconDetails, create new BeaconDetails object
      // completion could return an array of BeaconDetails, rather than individual one

      completion(content: BeaconDetails(beaconName: item.name, beaconColor: item.color))
    }
  }
}
