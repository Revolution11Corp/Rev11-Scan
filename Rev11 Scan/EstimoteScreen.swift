//
//  EstimoteScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/21/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//


import UIKit
import CoreLocation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class EstimoteScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, ESTDeviceManagerDelegate, ESTBeaconManagerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateView: UIView!

  var iBeacons: [EstimoteBeacon] = []
  var tempBeacons: [CLBeacon] = []

  let beaconManager = ESTBeaconManager()
  let deviceManager = ESTDeviceManager()
  let locationManager = CLLocationManager()
  let beaconDetailsCloudFactory = BeaconDetailsCloudFactory()

  let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: Keys.beaconRegionUUID)!, identifier: "example region")


  override func viewDidLoad() {
    super.viewDidLoad()
    checkForEmptyState()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
//    getTempFromDevice()

    locationManager.requestAlwaysAuthorization()
    locationManager.delegate = self
    beaconManager.delegate = self
    deviceManager.delegate = self
  }

//  func getTempFromDevice() {
//
//    let temperatureNotification = ESTTelemetryNotificationTemperature { (temperature) in
//      print("Current temperature: \(temperature.temperatureInCelsius) C")
//    }
//
//    deviceManager.registerForTelemetryNotification(temperatureNotification)
//  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    beaconManager.startRangingBeacons(in: beaconRegion)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    beaconManager.stopRangingBeacons(in: beaconRegion)
  }

  private func beaconManager(_ manager: AnyObject, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {

    let beaconNameArray: [String] = []

    // create a "tempBeacons" array to use as a comparision to most recent array. If the same = no network call
    // Fine for prototype, but if we go to production, will need to address this

    self.beaconDetailsCloudFactory.contentForBeacons(beacons) { (detailsArray) in

          self.setEstimoteNamesArray(detailsArray, namesArray: beaconNameArray, completion: { (result) in

            DispatchQueue.main.async {

              if result.count != 0 {

                self.iBeacons.removeAll()
                var counter = 0
                var sortedBeacons = beacons

                sortedBeacons.sort(by: { Int($0.minor) < Int($1.minor) })

                for beacon in sortedBeacons {

                  let proximity = BeaconHelper.intForProximity(beacon.proximity)
                  let newBeacon = EstimoteBeacon(name: result[counter], uuid: beacon.proximityUUID, majorValue: beacon.major, minorValue: beacon.minor, proximity: proximity, color: Colors.white)
                  
                  counter += 1
                  newBeacon.lastSeenEstimote = beacon
                  self.iBeacons.append(newBeacon)
                }

                self.iBeacons.sort(by: { $0.proximity < $1.proximity })
                self.checkForEmptyState()

                DispatchQueue.main.async {
                  self.tableView.reloadData()
                }

              } else {
                print("Results Array = 0")
              }
          }
        })
      }
  }

  
  func setEstimoteNamesArray(_ beaconDetailsArray: [BeaconDetails], namesArray: [String], completion: (_ result: [String]) -> Void) {

    var namesArray: [String] = namesArray

    for item in beaconDetailsArray {
      namesArray.append(item.beaconName)
    }

    completion(namesArray)
  }


  func showEmptyState(_ bool: Bool) {
    if bool == true {
      tableView.isHidden = true
      emptyStateView.isHidden = false
    } else {
      tableView.isHidden = false
      emptyStateView.isHidden = true
    }
  }

  func checkForEmptyState() {
    if iBeacons.count == 0 {
      showEmptyState(true)
    } else {
      showEmptyState(false)
    }
  }

  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Cells.estimoteCell, for: indexPath) as! EstimoteCell

    let beacon = iBeacons[(indexPath as NSIndexPath).row]
    cell.beacon = beacon

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)

    let beacon = iBeacons[(indexPath as NSIndexPath).row]
    let uuid = beacon.uuid!.uuidString
    let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.majorValue!)\nMinor: \(beacon.minorValue!)"
    let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

    present(detailAlert, animated: true, completion: nil)
  }


}

