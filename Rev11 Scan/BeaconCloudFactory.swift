//
//  BeaconCloudFactory.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/20/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

class BeaconDetailsCloudFactory {

  func contentForBeacons(beacons: [CLBeacon], completion: (content: [BeaconDetails]) -> ()) {

    var detailsArray: [BeaconDetails] = []

    let request = ESTRequestGetBeaconsDetails(beacons: beacons, andFields: ESTBeaconDetailsFields.FieldName)

    if beacons.count != 0 {
      let beaconOne = beacons[0].major
      let beaconTwo = beacons[1].major

      print("1st Major = \(beaconOne)\n2nd Major = \(beaconTwo)")

    }


    request.sendRequestWithCompletion { (beaconDetails, error) in

      if error != nil {
        print("sendRequestWithCompletion Error - \(error)")

      } else {
        for item in beaconDetails! {
          let newItem = BeaconDetails(beaconName: item.name, beaconColor: item.color)
          detailsArray.append(newItem)
        }

        let beaconOne = detailsArray[0].beaconName
        let beaconTwo = detailsArray[1].beaconName

        print("1st Name = \(beaconOne)\n2nd Name = \(beaconTwo)")
      }

      completion(content: detailsArray)
    }
  }
}
