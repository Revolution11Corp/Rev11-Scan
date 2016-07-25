//
//  EstimoteScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/21/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//


import UIKit
import CoreLocation

class EstimoteScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, ESTEddystoneManagerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var iBeacons: [iBeaconItem] = []
  var eddystoneItems: [ESTEddystone] = []
  let eddystoneManager = ESTEddystoneManager()
//  let estimoteCloudManager = ESTCloudManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    eddystoneManager.delegate = self
    findEddystones()
  }


  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eddystoneItems.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("EddystoneCell", forIndexPath: indexPath) as! EddystoneCell
    let eddystone = eddystoneItems[indexPath.row]
    let eddystoneProximity = eddystone.proximity.rawValue
    var proximityString: String?

    // Setting properties here will result in the typical issues when dequing cells. Refactor this to happen in the cell class (see how it's down with iBeacons)
    switch eddystoneProximity {
    case 1:
      proximityString = "Immediate"
      cell.backgroundColor = Colors.green
    case 2:
      proximityString = "Near"
      cell.backgroundColor = Colors.yellow
    case 3:
      proximityString = "Far"
      cell.backgroundColor = Colors.red
    default:
      proximityString = "Unknown"
    }

    let approximateDistance = (eddystone.rssi.floatValue)/(eddystone.measuredPower.floatValue)
    let distanceString = String(format: "\(proximityString!) (~ %.2f meters)", approximateDistance)

    cell.nameLabel.text = eddystone.peripheralIdentifier.UUIDString
    cell.locationLabel.text = distanceString

    return cell
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }


  //MARK: - Eddystone Methods

  func findEddystones() {

    let namespaceID = "EDD1EBEAC04E5DEFA017"
    //    let namespaceID = "EDD1EBEAC04E5DEF8888"
    let namespaceFilter = ESTEddystoneFilterUID(namespaceID: namespaceID)
    self.eddystoneManager.startEddystoneDiscoveryWithFilter(namespaceFilter)
  }

  func eddystoneManager(manager: ESTEddystoneManager, didDiscoverEddystones eddystones: [ESTEddystone], withFilter eddystoneFilter: ESTEddystoneFilter?) {

    eddystoneItems = eddystones
    eddystoneItems.sortInPlace({ $1.proximity.rawValue > $0.proximity.rawValue })

    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }
  
  func eddystoneManagerDidFailDiscovery(manager: ESTEddystoneManager, withError error: NSError?) {
    print("Did Fail Discovery")
  }

  //MARK: - Get Beacon Name

  func getEstimoteBeconNameFromCloud(beacons: [CLBeacon]) {

    let beaconDetailRequest = ESTRequestGetBeaconsDetails(beacons: beacons, andFields: ESTBeaconDetailsFields.FieldName)

    beaconDetailRequest.sendRequestWithCompletion { (beaconDetails, error) in
      print(beaconDetails)
    }

  }
  
}

