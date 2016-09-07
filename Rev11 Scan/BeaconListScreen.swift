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

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, ESTEddystoneManagerDelegate {

  @IBOutlet weak var tableView: UITableView!

//  var eddystoneScanner: EddystoneScanner!
  var iBeacons: [iBeaconItem] = []
//  var eddystones: [BeaconInfo] = []
  let locationManager = CLLocationManager()
  let eddystoneManager = ESTEddystoneManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    loadiBeacons()
//    setupEddystoneScanner()
    eddystoneManager.delegate = self

//    findEddystones()
  }

  @IBAction func readCSVPressed(_ sender: UIButton) {

    let defaults = UserDefaults(suiteName: "group.rev11scan")

    let data = defaults?.data(forKey: "spreadsheetFileAsData")

    print("data = \(data)")

    let dataString = String(data: data!, encoding: .utf8)

    print("dataString = \(dataString)")

    let csv = CSVParser(with: dataString!)

    let rows = csv.rows
    let headers = csv.headers
    let keyedRows = csv.keyedRows

    print("Rows = \(rows)")
    print("headers = \(headers)")
    print("keyedRows = \(keyedRows)")
  }


  func loadiBeacons() {
    if let storedBeacons = UserDefaults.standard.array(forKey: BeaconListScreenConstant.storedBeaconsKey) {

      for beaconData in storedBeacons {
        let beacon = NSKeyedUnarchiver.unarchiveObject(with: beaconData as! Data) as! iBeaconItem
        iBeacons.append(beacon)
        startMonitoringBeacon(beacon)
      }
    }
  }

  @IBAction func cancel(_ segue: UIStoryboardSegue) {
    // Do nothing
  }

  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "BeaconCell", for: indexPath) as! BeaconCell
    let beacon = iBeacons[(indexPath as NSIndexPath).row]

    cell.beacon = beacon

    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    if editingStyle == .delete {

      let beaconToRemove = iBeacons[(indexPath as NSIndexPath).row] as iBeaconItem
      stopMonitoringBeacon(beaconToRemove)
      tableView.beginUpdates()
      iBeacons.remove(at: (indexPath as NSIndexPath).row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      tableView.endUpdates()

      persistBeacons()
    }

  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)

    let beacon = iBeacons[(indexPath as NSIndexPath).row] as iBeaconItem
    let uuid = beacon.uuid.uuidString
    let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.majorValue)\nMinor: \(beacon.minorValue)"
    let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    present(detailAlert, animated: true, completion: nil)
  }

  //MARK: - Beacon Monitoring
  func startMonitoringBeacon(_ beacon: iBeaconItem) {
    let beaconRegion = beaconRegionWithItem(beacon)
    locationManager.startMonitoring(for: beaconRegion)
    locationManager.startRangingBeacons(in: beaconRegion)
    
  }

  func stopMonitoringBeacon(_ beacon: iBeaconItem) {
    let beaconRegion = beaconRegionWithItem(beacon)
    locationManager.stopMonitoring(for: beaconRegion)
    locationManager.stopRangingBeacons(in: beaconRegion)
  }

  func beaconRegionWithItem(_ beacon: iBeaconItem) -> CLBeaconRegion {
    let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid as UUID, major: beacon.majorValue, minor: beacon.minorValue, identifier: beacon.name)
    return beaconRegion
  }

  //MARK: - Save and Persist Beacons

  @IBAction func saveBeacon(_ segue: UIStoryboardSegue) {

    let addBeaconScreen = segue.source as! AddBeaconScreen

    if let newBeacon = addBeaconScreen.newBeacon {
      iBeacons.append(newBeacon)
      tableView.beginUpdates()

      let newIndexPath = IndexPath(row: iBeacons.count-1, section: 0)

      tableView.insertRows(at: [newIndexPath], with: .automatic)
      tableView.endUpdates()

      startMonitoringBeacon(newBeacon)
      persistBeacons()
    }
  }

  func persistBeacons() {
    var beaconsDataArray:[Data] = []

    for beacon in iBeacons {
      let beaconData = NSKeyedArchiver.archivedData(withRootObject: beacon)
      beaconsDataArray.append(beaconData)
    }

    UserDefaults.standard.set(beaconsDataArray, forKey: BeaconListScreenConstant.storedBeaconsKey)
  }

  //MARK: - Core Location Methods

  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Failed monitoring region: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location manager failed: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

    for beacon in beacons {

      for iBeacon in iBeacons {

        if iBeacon == beacon {
          iBeacon.lastSeenBeacon = beacon
          
        }
      }
    }
  }

  //MARK: - Eddystone Methods

//  func setupEddystoneScanner() {
//    eddystoneScanner = EddystoneScanner()
//    eddystoneScanner!.delegate = self
//    eddystoneScanner!.startScanning()
//  }
//
//  func didFindBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
////    NSLog("FIND: %@", beaconInfo.description)
//  }
//  func didLoseBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
////    NSLog("LOST: %@", beaconInfo.description)
//  }
//  func didUpdateBeacon(beaconScanner: EddystoneScanner, beaconInfo: BeaconInfo) {
////    NSLog("UPDATE: %@", beaconInfo.description)
//  }
//  func didObserveURLBeacon(beaconScanner: EddystoneScanner, URL: NSURL, RSSI: Int) {
////    NSLog("URL SEEN: %@, RSSI: %d", URL, RSSI)
//  }




//  func findEddystones() {
//
//    // filter by namespace
//    let namespaceID = "EDD1EBEAC04E5DEFA017"
////    let namespaceID = "EDD1EBEAC04E5DEF8888"
//    let namespaceFilter = ESTEddystoneFilterUID(namespaceID: namespaceID)
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(namespaceFilter)

//    // filter by URL
//    let urlFilter = ESTEddystoneFilterURL(URL: "http://my.restaurant.com/new-york-city")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(urlFilter)
//
//    // filter by domain name
//    let domainNameFilter = ESTEddystoneFilterURLDomain(URLDomain: "my.restaurant.com")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(domainNameFilter)






//  }

//  func eddystoneManager(manager: ESTEddystoneManager!, didDiscoverEddystones eddystones: [AnyObject]!, withFilter eddystoneFilter: ESTEddystoneFilter!) {
//
//    print(eddystones)
//
//
//  }

//  func eddystoneManager(manager: ESTEddystoneManager, didDiscoverEddystones eddystones: [ESTEddystone], withFilter eddystoneFilter: ESTEddystoneFilter?) {
////    print(eddystones)
//
//    for thing in eddystones {
//      print("UUID Sting = \(thing.peripheralIdentifier.UUIDString)")
//      print("Accuracy = \(thing.accuracy)")
//      print("Discovery Date = \(thing.discoveryDate)")
//      print("Is Equal To Eddystone (self) = \(thing.isEqualToEddystone(thing))")
//      print("Mac Address = \(thing.macAddress)")
//      print("Measured Power = \(thing.measuredPower)")
//      print("RSSI = \(thing.rssi)")
//      print("Proximity Zone = \(thing.proximity.rawValue)")
//    }
//
////      estimoteCloudManager.fetchBeaconDetails("D380ABAF-6096-5015-134D-39107D3CA712", completion: { (beacon, error) in
////      print(beacon.debug)
////     })
//  }
//
//  func eddystoneManagerDidFailDiscovery(manager: ESTEddystoneManager, withError error: NSError?) {
//    print("Did Fail Discovery")
//  }








}
