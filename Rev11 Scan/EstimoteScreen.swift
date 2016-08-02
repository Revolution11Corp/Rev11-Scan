//
//  EstimoteScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/21/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//


import UIKit
import CoreLocation

class EstimoteScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, ESTDeviceManagerDelegate, ESTBeaconManagerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateView: UIView!

  var iBeacons: [EstimoteBeacon] = []

  let beaconManager = ESTBeaconManager()
  let deviceManager = ESTDeviceManager()
  let beaconDetailsCloudFactory = BeaconDetailsCloudFactory()

  let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "example region")


  override func viewDidLoad() {
    super.viewDidLoad()
    checkForEmptyState()
    beaconManager.delegate = self
    deviceManager.delegate = self

    getTempFromDevice()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    beaconManager.startRangingBeaconsInRegion(beaconRegion)
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    beaconManager.stopRangingBeaconsInRegion(beaconRegion)
  }

  func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

    // create a "tempBeacons" array to use as a comparision to most recent array. If the same = no network call

    dispatch_async(dispatch_get_main_queue()) {
      self.beaconDetailsCloudFactory.contentForBeacons(beacons) { (content) in

        //If contentForBeacons now returns an array of "content", itereate through that array for what you need

        let name = content as! BeaconDetails

        print(name.beaconName)

      }
    }

    iBeacons.removeAll()

    for beacon in beacons {

      let newBeacon = EstimoteBeacon(name: "", uuid: beacon.proximityUUID, majorValue: beacon.major, minorValue: beacon.minor, color: Colors.white)

      newBeacon.lastSeenEstimote = beacon

      iBeacons.append(newBeacon)
    }

    checkForEmptyState()

    dispatch_async(dispatch_get_main_queue()) {
      self.tableView.reloadData()
    }
  }

  func showEmptyState(bool: Bool) {
    if bool == true {
      tableView.hidden = true
      emptyStateView.hidden = false
    } else {
      tableView.hidden = false
      emptyStateView.hidden = true
    }
  }

  func checkForEmptyState() {
    if iBeacons.count == 0 {
      showEmptyState(true)
    } else {
      showEmptyState(false)
    }
  }

  func getTempFromDevice() {

    let temperatureNotification = ESTTelemetryNotificationTemperature { (temperature) in
      print("Current temperature: \(temperature.temperatureInCelsius) C")
    }

    deviceManager.registerForTelemetryNotification(temperatureNotification)
  }

  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("EstimoteCell", forIndexPath: indexPath) as! EstimoteCell

    let beacon = iBeacons[indexPath.row]
    cell.beacon = beacon

    return cell
  }


}

