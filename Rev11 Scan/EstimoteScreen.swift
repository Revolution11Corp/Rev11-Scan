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
  var tempBeacons: [CLBeacon] = []

  let beaconManager = ESTBeaconManager()
  let deviceManager = ESTDeviceManager()
  let locationManager = CLLocationManager()
  let beaconDetailsCloudFactory = BeaconDetailsCloudFactory()

  let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: Keys.beaconRegionUUID)!, identifier: "example region")


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

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    beaconManager.startRangingBeaconsInRegion(beaconRegion)
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    beaconManager.stopRangingBeaconsInRegion(beaconRegion)
  }

  func beaconManager(manager: AnyObject, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {

    let beaconNameArray: [String] = []

    // create a "tempBeacons" array to use as a comparision to most recent array. If the same = no network call
    // Fine for prototype, but if we go to production, will need to address this

    self.beaconDetailsCloudFactory.contentForBeacons(beacons) { (detailsArray) in

          self.setEstimoteNamesArray(detailsArray, namesArray: beaconNameArray, completion: { (result) in

            dispatch_async(dispatch_get_main_queue()) {

              if result.count != 0 {

                self.iBeacons.removeAll()
                var counter = 0
                var sortedBeacons = beacons

                sortedBeacons.sortInPlace({ Int($0.minor) < Int($1.minor) })

                for beacon in sortedBeacons {

                  let proximity = BeaconHelper.intForProximity(beacon.proximity)
                  let newBeacon = EstimoteBeacon(name: result[counter], uuid: beacon.proximityUUID, majorValue: beacon.major, minorValue: beacon.minor, proximity: proximity, color: Colors.white)
                  
                  counter += 1
                  newBeacon.lastSeenEstimote = beacon
                  self.iBeacons.append(newBeacon)
                }

                self.iBeacons.sortInPlace({ $0.proximity < $1.proximity })
                self.checkForEmptyState()

                dispatch_async(dispatch_get_main_queue()) {
                  self.tableView.reloadData()
                }

              } else {
                print("Results Array = 0")
              }
          }
        })
      }
  }

  
  func setEstimoteNamesArray(beaconDetailsArray: [BeaconDetails], namesArray: [String], completion: (result: [String]) -> Void) {

    var namesArray: [String] = namesArray

    for item in beaconDetailsArray {
      namesArray.append(item.beaconName)
    }

    completion(result: namesArray)
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

  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(Cells.estimoteCell, forIndexPath: indexPath) as! EstimoteCell

    let beacon = iBeacons[indexPath.row]
    cell.beacon = beacon

    return cell
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let beacon = iBeacons[indexPath.row]
    let uuid = beacon.uuid!.UUIDString
    let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.majorValue!)\nMinor: \(beacon.minorValue!)"
    let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .Alert)
    detailAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))

    presentViewController(detailAlert, animated: true, completion: nil)
  }


}

