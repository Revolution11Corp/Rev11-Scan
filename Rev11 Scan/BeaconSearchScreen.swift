//
//  BeaconSearchScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 10/5/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconSearchScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  let locationManager = CLLocationManager()
  var iBeacons: [iBeaconItem] = []
  let defaults = UserDefaults(suiteName: Keys.suiteName)
  var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
  var UUIDFieldValid = false


  override func viewDidLoad() {
    super.viewDidLoad()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
    locationManager.delegate = self
  }

  @IBAction func changeUUIDButtonPressed(_ sender: UIBarButtonItem) {
    changeBeaconRegion()
  }

  func changeBeaconRegion() {

    let alertController = UIAlertController(title: "Change Beacons Detected", message: "Enter new UUID to change the Beacon Region", preferredStyle: .alert)
    let confirmAction = UIAlertAction(title: "Change UUID", style: .default) { (_) in

      if let field = alertController.textFields?[0] {

        let numberOfMatches = self.uuidRegex.numberOfMatches(in: field.text!, options: [], range: NSMakeRange(0, field.text!.characters.count))

        self.UUIDFieldValid = (numberOfMatches > 0)
        // store your data
        UserDefaults.standard.set(field.text, forKey: "BeaconRegion")

      } else {

        let failAlert = UIAlertController(title: "Invalid UUID", message: "Please enter a correct UUID", preferredStyle: .alert)
        failAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(failAlert, animated: true, completion: nil)
      }
    }

    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }

    alertController.addTextField { (textField) in
      textField.placeholder = "UUID"
    }

    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)

    self.present(alertController, animated: true, completion: nil)
  }


  @IBAction func cancel(_ segue: UIStoryboardSegue) {
    // Do nothing
  }

  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: Cells.beaconCell, for: indexPath) as! BeaconCell

    // New cell stuff (BeaconSearchCell) - Very basic.

//    let beacon = iBeacons[(indexPath as NSIndexPath).row]
//
//    cell.beacon = beacon
//
//    cell.nameLabel!.text = beacon.name
//    cell.typeLabel!.text = "Type: \(beacon.type)"
//    cell.actionURLButton.setTitle(beacon.actionURLName, for: .normal)
//    cell.beaconImage.image = beacon.itemImage
//
//    cell.actionURLButton.tag = indexPath.row
//    cell.actionURLButton.addTarget(self, action: #selector(BeaconListScreen.actionURLPressed(sender:)), for: .touchUpInside)

    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
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

    // Determine new beacon region based on user input.

    let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid as UUID, major: beacon.majorValue, minor: beacon.minorValue, identifier: beacon.name)
    return beaconRegion
  }

  //MARK: - Core Location Methods
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Failed monitoring region: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location manager failed: \(error.localizedDescription)")
  }
  
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

    // Do new array with the 'beacons' array from this delegate method.
    
//    for beacon in beacons {
//      
//      for iBeacon in iBeacons {
//        
//        if iBeacon == beacon {
//          iBeacon.lastSeenBeacon = beacon
//          
//        }
//      }
//    }
  }
}
