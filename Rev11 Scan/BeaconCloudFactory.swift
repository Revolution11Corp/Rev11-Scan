//
//  BeaconCloudFactory.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/20/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

class BeaconDetailsCloudFactory {

  func contentForBeacons(beacons: [CLBeacon], completion: (detailsArray: [BeaconDetails]) -> ()) {

    var detailsArray: [BeaconDetails] = []

    let request = ESTRequestGetBeaconsDetails(beacons: beacons, andFields: [ESTBeaconDetailsFields.AllFields, ESTBeaconDetailsFields.AllSettings])

    request.sendRequestWithCompletion { (beaconDetails, error) in

      var beaconVOObjects: [ESTBeaconVO] = []

      if error != nil {
        print("sendRequestWithCompletion Error - \(error)")

      } else {

        for item in beaconDetails! {
          let tempItem = item as! ESTBeaconVO
          beaconVOObjects.append(tempItem)
        }

        beaconVOObjects.sortInPlace({ Int($0.minor) < Int($1.minor) })

        for beaconVO in beaconVOObjects {

          let newItem = BeaconDetails(beaconName: beaconVO.name!, beaconColor: beaconVO.color)
          detailsArray.append(newItem)
        }
      }

      completion(detailsArray: detailsArray)
    }
  }
}
