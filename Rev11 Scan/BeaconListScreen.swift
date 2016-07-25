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
  static let storedEddystones = "storedEddystones"
}

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, BeaconScannerDelegate, ESTEddystoneManagerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var eddystoneScanner: EddystoneScanner!
  var iBeacons: [iBeaconItem] = []
  var eddystones: [BeaconInfo] = []
  let locationManager = CLLocationManager()
  let eddystoneManager = ESTEddystoneManager()
//  let estimoteCloudManager = ESTCloudManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    loadiBeacons()
//    loadEddystones()
    setupEddystoneScanner()
    eddystoneManager.delegate = self

    findEddystones()
  }

  func loadiBeacons() {
    if let storedBeacons = NSUserDefaults.standardUserDefaults().arrayForKey(BeaconListScreenConstant.storedBeaconsKey) {

      for beaconData in storedBeacons {
        let beacon = NSKeyedUnarchiver.unarchiveObjectWithData(beaconData as! NSData) as! iBeaconItem
        iBeacons.append(beacon)
        startMonitoringBeacon(beacon)
      }
    }
  }

//  func loadEddystones() {
//    if let storedEddystones = NSUserDefaults.standardUserDefaults().arrayForKey(BeaconListScreenConstant.storedEddystones) {
//
//      for eddystoneData in storedEddystones {
//        let eddystone = NSKeyedUnarchiver.unarchiveObjectWithData(eddystoneData as! NSData) as! BeaconInfo
//        eddystones.append(eddystone)
//
//        // Replace this with Eddystone version
//        // startMonitoringBeacon(beacon)
//      }
//    }
//  }

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
//    NSLog("FIND: %@", beaconInfo.description)
  }
  func didLoseBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
//    NSLog("LOST: %@", beaconInfo.description)
  }
  func didUpdateBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
//    NSLog("UPDATE: %@", beaconInfo.description)
  }
  func didObserveURLBeacon(beaconScanner: EddystoneScanner, URL: NSURL, RSSI: Int) {
//    NSLog("URL SEEN: %@, RSSI: %d", URL, RSSI)
  }




  func findEddystones() {

    // filter by namespace
    let namespaceID = "EDD1EBEAC04E5DEFA017"
//    let namespaceID = "EDD1EBEAC04E5DEF8888"
    let namespaceFilter = ESTEddystoneFilterUID(namespaceID: namespaceID)
    self.eddystoneManager.startEddystoneDiscoveryWithFilter(namespaceFilter)

//    // filter by URL
//    let urlFilter = ESTEddystoneFilterURL(URL: "http://my.restaurant.com/new-york-city")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(urlFilter)
//
//    // filter by domain name
//    let domainNameFilter = ESTEddystoneFilterURLDomain(URLDomain: "my.restaurant.com")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(domainNameFilter)






  }

//  func eddystoneManager(manager: ESTEddystoneManager!, didDiscoverEddystones eddystones: [AnyObject]!, withFilter eddystoneFilter: ESTEddystoneFilter!) {
//
//    print(eddystones)
//
//
//  }

  func eddystoneManager(manager: ESTEddystoneManager, didDiscoverEddystones eddystones: [ESTEddystone], withFilter eddystoneFilter: ESTEddystoneFilter?) {
//    print(eddystones)

    for thing in eddystones {
      print("UUID Sting = \(thing.peripheralIdentifier.UUIDString)")
      print("Accuracy = \(thing.accuracy)")
      print("Discovery Date = \(thing.discoveryDate)")
      print("Is Equal To Eddystone (self) = \(thing.isEqualToEddystone(thing))")
      print("Mac Address = \(thing.macAddress)")
      print("Measured Power = \(thing.measuredPower)")
      print("RSSI = \(thing.rssi)")
      print("Proximity Zone = \(thing.proximity.rawValue)")
    }

//      estimoteCloudManager.fetchBeaconDetails("D380ABAF-6096-5015-134D-39107D3CA712", completion: { (beacon, error) in
//      print(beacon.debug)
//     })
  }

  func eddystoneManagerDidFailDiscovery(manager: ESTEddystoneManager, withError error: NSError?) {
    print("Did Fail Discovery")
  }








}
