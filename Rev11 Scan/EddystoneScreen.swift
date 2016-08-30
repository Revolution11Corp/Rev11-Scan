//
//  EddystoneScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/23/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class EddystoneScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, ESTEddystoneManagerDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var emptyStateView: UIView!

  var iBeacons: [iBeaconItem] = []
  var eddystoneItems: [ESTEddystone] = []
  let eddystoneManager = ESTEddystoneManager()

  override func viewDidLoad() {
    super.viewDidLoad()
    eddystoneManager.delegate = self
    findEddystones()
    checkForEmptyState()
    NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
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
    if eddystoneItems.count == 0 {
      showEmptyState(true)
    } else {
      showEmptyState(false)
    }
  }


  //MARK: - TableView Methods
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return eddystoneItems.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: Cells.eddystoneCell, for: indexPath) as! EddystoneCell
    let eddystone = eddystoneItems[(indexPath as NSIndexPath).row]
    let eddystoneProximity = eddystone.proximity.rawValue
    var proximityString: String?

    // Setting properties here will result in the typical issues when dequing cells. Refactor this to happen in the cell class (see how it's done with iBeacons)
    switch eddystoneProximity {
    case 1:
      proximityString = "Immediate"
      cell.backgroundColor = Colors.green
    case 2:
      proximityString = "Near"
      cell.backgroundColor = Colors.yellow
    case 3:
      proximityString = "Far"
      cell.backgroundColor = Colors.red
    default:
      proximityString = "Unknown"
    }

    let approximateDistance = (eddystone.rssi.floatValue)/(eddystone.measuredPower.floatValue)
    let distanceString = String(format: "\(proximityString!) (~ %.2f meters)", approximateDistance)

    cell.nameLabel.text = eddystone.peripheralIdentifier.uuidString
    cell.locationLabel.text = distanceString

    return cell
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  //MARK: - Eddystone Methods

  func findEddystones() {

//    let namespaceID = "EDD1EBEAC04E5DEFA017"
//    let namespaceFilter = ESTEddystoneFilterUID(namespaceID: namespaceID)
    self.eddystoneManager.startEddystoneDiscovery(with: nil)

  }


  func eddystoneManager(_ manager: ESTEddystoneManager, didDiscover eddystones: [ESTEddystone], with eddystoneFilter: ESTEddystoneFilter?) {

    eddystoneItems = eddystones
    eddystoneItems.sort(by: { $1.proximity.rawValue > $0.proximity.rawValue })
    checkForEmptyState()

    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }

  private func eddystoneManagerDidFailDiscovery(_ manager: ESTEddystoneManager, withError error: NSError?) {
    print("Did Fail Discovery")
  }
  
}
