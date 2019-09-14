//
//  BeaconSearchScreen.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 10/5/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconSearchScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var segmentedControl: RVSegmentedControl!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var updateUUIDView: UIView!
    
    @IBOutlet weak var uuidOneTextField: RVTextField!
    @IBOutlet weak var uuidTwoTextField: RVTextField!
    @IBOutlet weak var uuidThreeTextField: RVTextField!
    
    @IBOutlet var textFields: [RVTextField]!
    
    let locationManager = CLLocationManager()
    var iBeacons: [CLBeacon] = []
    let defaults = UserDefaults(suiteName: Keys.suiteName)
    var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    var UUIDFieldValid = false
    var transparencyView: UIView!
    
    var regionOne: String!
    var regionTwo: String!
    var regionThree: String!
    
    var regionUUID: UUID!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparencyView = createTransparencyView()
        NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
        locationManager.delegate = self
        setDefaultRegions()
        tableView.hideExcessSeparatorLines()
        segmentedControl.selectedIndex = 0
        
        let beaconRegion = CLBeaconRegion(proximityUUID: regionOne.convertToUUID(), identifier: "Selected Region")
        locationManager.startRangingBeacons(in: beaconRegion)
        
        uuidLabel.text = regionOne
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        uuidOneTextField.text = regionOne
        uuidTwoTextField.text = regionTwo
        uuidThreeTextField.text = regionThree
        
        updateUUIDView.layer.cornerRadius = 12
    }
    
    @IBAction func editRegionsPressed(_ sender: UIBarButtonItem) {
        showUpdateUUIDView(bool: true)
    }
    
    @IBAction func uuidViewCancelPressed(_ sender: UIButton) {
        showUpdateUUIDView(bool: false)
    }
    
    @IBAction func updateUUIDsPressed(_ sender: RVButton) {
        updateBeaconRegions()
    }
    
    func showUpdateUUIDView(bool: Bool) {
        UIView.animate(withDuration: 0.33, animations: {
            self.transparencyView.alpha = bool ? 0.7 : 0.0
            self.updateUUIDView.alpha = bool ? 1.0 : 0.0
            self.view.bringSubviewToFront(self.updateUUIDView)
        })
    }
    
    func updateBeaconRegions() {
        
        for (index, textField) in textFields.enumerated() {
            
            let numberOfMatches = self.uuidRegex.numberOfMatches(in: textField.text!, options: [], range: NSMakeRange(0, textField.text!.count))
            UUIDFieldValid = (numberOfMatches > 0)
            
            if UUIDFieldValid == false {
                let failAlert = UIAlertController(title: "UUID \(String(index + 1)) Invalid", message: "Please enter a correct UUID", preferredStyle: .alert)
                failAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(failAlert, animated: true, completion: nil)
                
                return
            }
        }
        
        Constants.defaults.set(uuidOneTextField.text, forKey: Keys.uuidOneKey)
        Constants.defaults.set(uuidTwoTextField.text, forKey: Keys.uuidTwoKey)
        Constants.defaults.set(uuidThreeTextField.text, forKey: Keys.uuidThreeKey)
        
        regionOne = Constants.defaults.object(forKey: Keys.uuidOneKey) as! String
        regionTwo = Constants.defaults.object(forKey: Keys.uuidTwoKey) as! String
        regionThree = Constants.defaults.object(forKey: Keys.uuidThreeKey) as! String
        
        showUpdateUUIDView(bool: false)
    }
    
    func setDefaultRegions() {
        if Constants.defaults.object(forKey: Keys.uuidOneKey) == nil {
            Constants.defaults.set(UUIDs.one, forKey: Keys.uuidOneKey)
        }
        
        if Constants.defaults.object(forKey: Keys.uuidTwoKey) == nil {
            Constants.defaults.set(UUIDs.two, forKey: Keys.uuidTwoKey)
        }
        
        if Constants.defaults.object(forKey: Keys.uuidThreeKey) == nil {
            Constants.defaults.set(UUIDs.three, forKey: Keys.uuidThreeKey)
        }
        
        regionOne = Constants.defaults.object(forKey: Keys.uuidOneKey) as! String
        regionTwo = Constants.defaults.object(forKey: Keys.uuidTwoKey) as! String
        regionThree = Constants.defaults.object(forKey: Keys.uuidThreeKey) as! String
    }
    
    @IBAction func segmentedControlTapped(_ sender: RVSegmentedControl) {
        
        switch segmentedControl.selectedIndex {
            
        case 0:
            regionUUID = regionOne.convertToUUID()
            uuidLabel.text = regionOne
        case 1:
            regionUUID = regionTwo.convertToUUID()
            uuidLabel.text = regionTwo
        case 2:
            regionUUID = regionThree.convertToUUID()
            uuidLabel.text = regionThree
        default:
            regionUUID = regionOne.convertToUUID()
            uuidLabel.text = regionOne
        }
        
        let beaconRegion = CLBeaconRegion(proximityUUID: regionUUID, identifier: "Selected Region")
        locationManager.startRangingBeacons(in: beaconRegion)
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
            updateCellUI(cell, textColor: Colors.darkGrey, distanceValue: "Weak Signal")
            proximityText = "--"
            
        case .immediate:
            updateCellUI(cell, textColor: Colors.green, distanceValue: "~ < 1 meter")
            proximityText =  "Close"
            
        case .near:
            updateCellUI(cell, textColor: Colors.yellow, distanceValue: "~ 1-3 meters")
            proximityText = "Near"
            
        case .far:
            updateCellUI(cell, textColor: Colors.red, distanceValue: "~ 3+ meters")
            proximityText = "Far"
        }
        
        cell.majorMinorLabel.text = "Major:  \(beacon.major.stringValue)" + "\nMinor:  \(beacon.minor.stringValue)"
        cell.locationLabel.text = "\(proximityText)"
        
        return cell
    }
    
    func updateCellUI(_ cell: BeaconSearchCell, textColor: UIColor, distanceValue: String) {
        cell.locationLabel.textColor = textColor
        cell.distanceLabel.text = distanceValue
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
        tableView.alpha = beacons.count == 0 ? 0.0 : 1.0
        tableView.reloadDataOnMainThread()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
}
