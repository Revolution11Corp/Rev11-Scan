//
//  BeaconListScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices

struct BeaconListScreenConstant {
  static let storedBeaconsKey = "storedBeacons"
  static let storedEddystones = "storedEddystones"
}

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

  @IBOutlet weak var tableView: UITableView!

  var iBeacons: [iBeaconItem] = []
  let locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    readSharedCSV()
  }

  func readSharedCSV() {
    // handle empty state for when a CSV has not been shared yet.

    let defaults = UserDefaults(suiteName: "group.rev11scan")
    let data = defaults?.data(forKey: "spreadsheetFileAsData")
    let dataString = String(data: data!, encoding: .utf8)

    let csv = CSVParser(with: dataString!)

    for object in csv.keyedRows! {

      //Need to handle nils, for when the spreadsheet has blank spots
      let name = object["Beacon Name"]
      let uuid = object["UUID"]?.convertToUUID()
      let major = object["Major"]?.convertToMajorValue()
      let minor = object["Minor"]?.convertToMinorValue()
      let imageURL = object["Image URL"]
      let actionURL = object["Action URL"]
      let color = Colors.white

      let newBeacon = iBeaconItem(name: name!, uuid: uuid!, majorValue: major, minorValue: minor, imageURL: imageURL!, actionURL: actionURL!, color: color)

      iBeacons.append(newBeacon)
      startMonitoringBeacon(newBeacon)
    }
    
    tableView.reloadData()
  }

//  @IBAction func readCSVPressed(_ sender: UIButton) {
//
//    let defaults = UserDefaults(suiteName: "group.rev11scan")
//
//    let data = defaults?.data(forKey: "spreadsheetFileAsData")
//
//    print("data = \(data)")
//
//    let dataString = String(data: data!, encoding: .utf8)
//
//    print("dataString = \(dataString)")
//
//    let csv = CSVParser(with: dataString!)
//
//    let rows = csv.rows
//    let headers = csv.headers
//    let keyedRows = csv.keyedRows
//
//    print("Rows = \(rows)")
//    print("headers = \(headers)")
//    print("keyedRows = \(keyedRows)")
//
//    print("Keyed Rows Count = \(keyedRows?.count)")
//
//    for object in keyedRows! {
//
//      //Need to handle nils, for when the spreadsheet has blank spots
//      let name = object["Beacon Name"]
//      let uuid = object["UUID"]?.convertToUUID()
//      let major = object["Major"]?.convertToMajorValue()
//      let minor = object["Minor"]?.convertToMinorValue()
//      let imageURL = object["Image URL"]
//      let actionURL = object["Action URL"]
//      let color = Colors.white
//
//      let newBeacon = iBeaconItem(name: name!, uuid: uuid!, majorValue: major, minorValue: minor, imageURL: imageURL!, actionURL: actionURL!, color: color)
//
//      iBeacons.append(newBeacon)
//      startMonitoringBeacon(newBeacon)
//
//      
//    }
//
//    tableView.reloadData()
//  }

//  func loadiBeacons() {
//    if let storedBeacons = UserDefaults.standard.array(forKey: BeaconListScreenConstant.storedBeaconsKey) {
//
//      for beaconData in storedBeacons {
//        let beacon = NSKeyedUnarchiver.unarchiveObject(with: beaconData as! Data) as! iBeaconItem
//        iBeacons.append(beacon)
//        startMonitoringBeacon(beacon)
//      }
//    }
//  }

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
    cell.actionURLButton.tag = indexPath.row
    cell.actionURLButton.addTarget(self, action: #selector(BeaconListScreen.actionURLPressed(sender:)), for: .touchUpInside)

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

  func actionURLPressed(sender: UIButton) {

    let beaconRow = sender.tag
    let selectedBeacon = iBeacons[beaconRow]

    let url = URL(string: (selectedBeacon.actionURL))
    let vc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
    present(vc, animated: true, completion: nil)
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
}
