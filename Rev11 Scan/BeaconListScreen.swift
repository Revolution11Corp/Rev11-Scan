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

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

  let locationManager = CLLocationManager()
  var iBeacons: [iBeaconItem] = []
  var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
  var UUIDFieldValid = false


  override func viewDidLoad() {
    super.viewDidLoad()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()

  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    // add check for if/when a new spreadsheet has been loaded

    if UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) != nil {
      loadStoredBeacons()
    } else {

      readSharedCSV { () -> () in

        self.tableView.isHidden = false
        self.persistBeacons()

        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.tableView.reloadData()
        }
      }
    }
  }

  func loadStoredBeacons() {

    if let storedBeacons = UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) {
      
      for beaconData in storedBeacons {
        let beacon = NSKeyedUnarchiver.unarchiveObject(with: (beaconData as! NSData) as Data) as! iBeaconItem
        startMonitoringBeacon(beacon)
        iBeacons.append(beacon)
      }
    }
  }

  func readSharedCSV(completionHandler: @escaping (() -> ())) {

    activityIndicator.startAnimating()
    iBeacons.removeAll()

    let defaults = UserDefaults(suiteName: Keys.suiteName)

    print("spreadsheet = \(defaults?.data(forKey: Keys.spreadsheetFile))")

    if defaults?.data(forKey: Keys.spreadsheetFile) != nil {

      let data = defaults?.data(forKey: Keys.spreadsheetFile)
      let dataString = String(data: data!, encoding: .utf8)

      let csv = CSVParser(with: dataString!)
      let csvCount = csv.keyedRows!.count
      var beaconCounter = 0

      for object in csv.keyedRows! {

        var newBeacon: iBeaconItem?

        //Need to handle nils, for when the spreadsheet has blank spots
        let name = object["Beacon Name"]
        let uuid = object["UUID"]?.convertToUUID()
        let major = object["Major"]?.convertToMajorValue()
        let minor = object["Minor"]?.convertToMinorValue()
        let actionURL = object["Action URL"]
        let color = Colors.white

        if let imageURL = object["Image URL"] {

          let convertedURL = NSURL(string: imageURL)
          let networking = Networking(url: convertedURL!)

          networking.downloadImage(completion: { (imageData) in

            let itemImage = UIImage(data: imageData)
            newBeacon = iBeaconItem(name: name!, uuid: uuid!, majorValue: major, minorValue: minor, itemImage: itemImage!, actionURL: actionURL!, color: color)
            self.startMonitoringBeacon(newBeacon!)
            self.iBeacons.append(newBeacon!)

            beaconCounter += 1

            if beaconCounter == csvCount {
              completionHandler()
            }
          })
        }
      }
    } else {
      tableView.isHidden = true
    }
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

  func persistBeacons() {

    var beaconsDataArray:[Data] = []

    for beacon in iBeacons {
      let beaconData = NSKeyedArchiver.archivedData(withRootObject: beacon)
      beaconsDataArray.append(beaconData)
    }

    UserDefaults.standard.set(beaconsDataArray, forKey: BeaconProperties.storedBeaconArrayKey)
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
