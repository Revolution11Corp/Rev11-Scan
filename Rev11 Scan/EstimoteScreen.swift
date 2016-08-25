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

  let beaconRegion = CLBeaconRegion(proximityUUID: NSUUID(UUIDString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!, identifier: "example region")


  override func viewDidLoad() {
    super.viewDidLoad()
    checkForEmptyState()
    showLogoInNavBar()
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

//    let beaconOne = beacons[0].major
//    let beaconTwo = beacons[1].major
//
//    print("1st = \(beaconOne)\n2nd = \(beaconTwo)")

    let beaconNameArray: [String] = []

    // create a "tempBeacons" array to use as a comparision to most recent array. If the same = no network call
    // Fine for prototype, but if we go to production, will need to address this

    self.beaconDetailsCloudFactory.contentForBeacons(beacons) { (detailsArray) in

//      let beaconOne = content[0].beaconName
//      let beaconTwo = content[1].beaconName
//
//      print("1st = \(beaconOne)\n2nd = \(beaconTwo)")

//      DetailsArray - an array of beaconDetails ordered by Minor
//
//      result - array of name strings ordered by Minor

          self.setEstimoteNamesArray(detailsArray, namesArray: beaconNameArray, completion: { (result) in

            dispatch_async(dispatch_get_main_queue()) {

              if result.count != 0 {

                self.iBeacons.removeAll()

                var counter = 0

                var sortedBeacons = beacons

                sortedBeacons.sortInPlace({ Int($0.minor) < Int($1.minor) })

                for beacon in sortedBeacons {

                  let newBeacon = EstimoteBeacon(name: result[counter], uuid: beacon.proximityUUID, majorValue: beacon.major, minorValue: beacon.minor, color: Colors.white)
                  
                  counter += 1
                  newBeacon.lastSeenEstimote = beacon
                  self.iBeacons.append(newBeacon)

                }

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

  func showLogoInNavBar() {
    let banner = UIImage(named: "logo-nav-bar")
    let imageView = UIImageView(image:banner)
    let bannerWidth = navigationController?.navigationBar.frame.size.width
    let bannerHeight = navigationController?.navigationBar.frame.size.height
    let bannerX = bannerWidth! / 2 - banner!.size.width / 2
    let bannerY = bannerHeight! / 2 - banner!.size.height / 2
    imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth!, height: bannerHeight!)
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    self.navigationItem.titleView = imageView
  }


  //MARK: - TableView Methods
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return iBeacons.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCellWithIdentifier("EstimoteCell", forIndexPath: indexPath) as! EstimoteCell

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

