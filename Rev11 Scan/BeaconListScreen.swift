//
//  BeaconListScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

struct BeaconListScreenConstant {
  static let storedBeaconsKey = "storedBeacons"
}

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, BeaconScannerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var eddystoneScanner: EddystoneScanner!
  var iBeacons: [iBeaconItem] = []
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    loadBeacons()
    //    setupEddystoneScanner()

  }

  func loadBeacons() {
    if let storedBeacons = NSUserDefaults.standardUserDefaults().arrayForKey(BeaconListScreenConstant.storedBeaconsKey) {

      for beaconData in storedBeacons {
        let beacon = NSKeyedUnarchiver.unarchiveObjectWithData(beaconData as! NSData) as! iBeaconItem
        iBeacons.append(beacon)
        startMonitoringBeacon(beacon)
      }
    }
  }

  @IBAction func cancel(segue: UIStoryboardSegue) {
    // Do nothing
  }

  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as! BeaconCell
    let beacon = iBeacons[indexPath.row]

    cell.beacon = beacon

    return cell
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    if editingStyle == .Delete {

      let beaconToRemove = iBeacons[indexPath.row] as iBeaconItem
      stopMonitoringBeacon(beaconToRemove)
      tableView.beginUpdates()
      iBeacons.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
      tableView.endUpdates()

      persistBeacons()
    }

  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let beacon = iBeacons[indexPath.row] as iBeaconItem
    let uuid = beacon.uuid.UUIDString
    let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.majorValue)\nMinor: \(beacon.minorValue)"
    let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .Alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

    presentViewController(detailAlert, animated: true, completion: nil)
  }

  //MARK: - Beacon Monitoring
  func startMonitoringBeacon(beacon: iBeaconItem) {
    let beaconRegion = beaconRegionWithItem(beacon)
    locationManager.startMonitoringForRegion(beaconRegion)
    locationManager.startRangingBeaconsInRegion(beaconRegion)
    
  }

  func stopMonitoringBeacon(beacon: iBeaconItem) {
    let beaconRegion = beaconRegionWithItem(beacon)
    locationManager.stopMonitoringForRegion(beaconRegion)
    locationManager.stopRangingBeaconsInRegion(beaconRegion)
  }

  func beaconRegionWithItem(beacon: iBeaconItem) -> CLBeaconRegion {
    let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid, major: beacon.majorValue, minor: beacon.minorValue, identifier: beacon.name)
    return beaconRegion
  }

  //MARK: - Save and Persist Beacons

  @IBAction func saveBeacon(segue: UIStoryboardSegue) {

    let addBeaconScreen = segue.sourceViewController as! AddBeaconScreen

    if let newBeacon = addBeaconScreen.newBeacon {
      iBeacons.append(newBeacon)
      tableView.beginUpdates()

      let newIndexPath = NSIndexPath(forRow: iBeacons.count-1, inSection: 0)

      tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
      tableView.endUpdates()

      startMonitoringBeacon(newBeacon)
      persistBeacons()
    }
  }

  func persistBeacons() {
    var beaconsDataArray:[NSData] = []

    for beacon in iBeacons {
      let beaconData = NSKeyedArchiver.archivedDataWithRootObject(beacon)
      beaconsDataArray.append(beaconData)
    }

    NSUserDefaults.standardUserDefaults().setObject(beaconsDataArray, forKey: BeaconListScreenConstant.storedBeaconsKey)
  }

  //MARK: - Core Location Methods

  func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
    print("Failed monitoring region: \(error.description)")
  }

  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    print("Location manager failed: \(error.description)")
  }

  func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

    for beacon in beacons {

      for iBeacon in iBeacons {

        if iBeacon == beacon {
          iBeacon.lastSeenBeacon = beacon
        }
      }
    }
  }

  //MARK: - Eddystone Methods

  func setupEddystoneScanner() {
    eddystoneScanner = EddystoneScanner()
    eddystoneScanner!.delegate = self
    eddystoneScanner!.startScanning()
  }

  func didFindBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
    NSLog("FIND: %@", beaconInfo.description)
  }
  func didLoseBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
    NSLog("LOST: %@", beaconInfo.description)
  }
  func didUpdateBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
    NSLog("UPDATE: %@", beaconInfo.description)
  }
  func didObserveURLBeacon(beaconScanner: EddystoneScanner, URL: NSURL, RSSI: Int) {
    NSLog("URL SEEN: %@, RSSI: %d", URL, RSSI)
  }
  
  
  
  
  
}
