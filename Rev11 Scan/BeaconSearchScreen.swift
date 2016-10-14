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
  @IBOutlet weak var uuidSearchField: UITextField!

  let locationManager = CLLocationManager()
  var iBeacons: [CLBeacon] = []
  let defaults = UserDefaults(suiteName: Keys.suiteName)
  var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
  var UUIDFieldValid = false


  override func viewDidLoad() {
    super.viewDidLoad()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
    locationManager.delegate = self
  }

  func changeBeaconRegion() {

    if let field = self.uuidSearchField {

      let numberOfMatches = self.uuidRegex.numberOfMatches(in: field.text!, options: [], range: NSMakeRange(0, field.text!.characters.count))

      self.UUIDFieldValid = (numberOfMatches > 0)
      print(UUIDFieldValid)

      let beaconRegion = CLBeaconRegion(proximityUUID: (field.text?.convertToUUID())!, identifier: "Searched Region")
      locationManager.startRangingBeacons(in: beaconRegion)
      print(beaconRegion)

      UserDefaults.standard.set(field.text, forKey: "BeaconRegion")

    } else {

      let failAlert = UIAlertController(title: "Invalid UUID", message: "Please enter a correct UUID", preferredStyle: .alert)
      failAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

      self.present(failAlert, animated: true, completion: nil)
    }
  }

  @IBAction func searchButtonPressed(_ sender: UIButton) {
    changeBeaconRegion()
  }

  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: Cells.beaconSearchCell, for: indexPath) as! BeaconSearchCell

    let beacon = iBeacons[(indexPath as NSIndexPath).row]
    var proximityText = "Unknown"

    switch beacon.proximity {

    case .unknown:
      cell.backgroundColor = Colors.white
      proximityText = "Unknown"


    case .immediate:
      cell.backgroundColor = Colors.green
      proximityText =  "Immediate"

    case .near:
      cell.backgroundColor = Colors.yellow
      proximityText = "Near"

    case .far:
      cell.backgroundColor = Colors.red
      proximityText = "Far"
    }

    cell.uuidLabel.text = beacon.proximityUUID.uuidString
    cell.majorMinorLabel.text = "Major: \(beacon.major.stringValue)    Minor: \(beacon.minor.stringValue)"
    cell.locationLabel.text = "\(proximityText) (approx. \(NSString(format: "%.2f", beacon.accuracy))m)"

    return cell
  }

  //MARK: - Core Location Methods
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Failed monitoring region: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location manager failed: \(error.localizedDescription)")
  }

  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    iBeacons = beacons

    iBeacons.sort(by: { $0.major.intValue > $1.major.intValue })

    print(beacons.count)
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
}
