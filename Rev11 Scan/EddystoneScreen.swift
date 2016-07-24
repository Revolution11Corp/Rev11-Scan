//
//  EddystoneScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/23/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class EddystoneScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, BeaconScannerDelegate, ESTEddystoneManagerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var eddystoneScanner: EddystoneScanner!
  var iBeacons: [iBeaconItem] = []
  var eddystones: [BeaconInfo] = []
  let eddystoneManager = ESTEddystoneManager()
  let estimoteCloudManager = ESTCloudManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    //    loadEddystones()
    setupEddystoneScanner()
    eddystoneManager.delegate = self
//    findEddystones()
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



  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("BeaconCell", forIndexPath: indexPath) as! BeaconCell
//    let beacon = iBeacons[indexPath.row]
//
//    cell.beacon = beacon

    return cell
  }

  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }


  //  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
  //
  //    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  //
  //    let beacon = iBeacons[indexPath.row] as iBeaconItem
  //    let uuid = beacon.uuid.UUIDString
  //    let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.majorValue)\nMinor: \(beacon.minorValue)"
  //    let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .Alert)
  //    detailAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
  //
  //    presentViewController(detailAlert, animated: true, completion: nil)
  //  }


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
      //      print("UUID Sting = \(thing.peripheralIdentifier.UUIDString)")
      //      print("Accuracy = \(thing.accuracy)")
      //      print("Discovery Date = \(thing.discoveryDate)")
      //      print("Is Equal To Eddystone (self) = \(thing.isEqualToEddystone(thing))")
      //      print("Mac Address = \(thing.macAddress)")
      //      print("Measured Power = \(thing.measuredPower)")
      //      print("RSSI = \(thing.rssi)")
      //      print("Proximity Zone = \(thing.proximity.rawValue)")
    }

    //      estimoteCloudManager.fetchBeaconDetails("D380ABAF-6096-5015-134D-39107D3CA712", completion: { (beacon, error) in
    //      print(beacon.debug)
    //     })
  }

  func eddystoneManagerDidFailDiscovery(manager: ESTEddystoneManager, withError error: NSError?) {
    print("Did Fail Discovery")
  }
  
  
  
  
  
  
  
  
}
