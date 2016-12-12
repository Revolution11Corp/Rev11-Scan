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
import MobileCoreServices

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateIcon: UIImageView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var permissionsView: UIView!
    @IBOutlet weak var filterBarButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults(suiteName: Keys.suiteName)
    var iBeacons: [iBeaconItem] = []
    var filteredBeacons: [iBeaconItem] = []
    
    var transparencyView: UIView!
    var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    
    var isFiltered = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transparencyView = createTransparencyView()
        NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(BeaconListScreen.reloadViewFromBackground), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    func reloadViewFromBackground() {
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingCSV()
        
        if Constants.defaults.bool(forKey: Keys.hasViewedPermissions) != true {
            showPermissionsView(bool: true)
        }
    }
    
    func checkForExistingCSV() {
        
        if UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) != nil {
            
            if defaults?.bool(forKey: Keys.isNewSharedSpreadsheet) == false {
                loadStoredBeacons()
                setupBeaconRegions()
            } else {
                readSharedCSVWithClosure()
            }
        } else {
            readSharedCSVWithClosure()
        }
    }
    
    func showPermissionsView(bool: Bool) {
        
        UIView.animate(withDuration: 0.33, animations: {
            self.transparencyView.alpha = bool ? 0.7 : 0.0
            self.permissionsView.alpha = bool ? 1.0 : 0.0
            self.view.bringSubview(toFront: self.permissionsView)
        })
    }
    
    @IBAction func permissionsOKButtonPressed(_ sender: RVButton) {
        showPermissionsView(bool: false)
        Constants.defaults.set(true, forKey: Keys.hasViewedPermissions)
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupBeaconRegions() {
        
        let beaconRegions: [iBeaconItem] = iBeacons.filterDuplicates { $0.uuid == $1.uuid && $0.uuid == $1.uuid }
        
        for beacon in beaconRegions {
            startRangingBeacon(beacon)
        }
    }
    
    func loadStoredBeacons() {
        
        if let storedBeacons = UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) {
            
            for beaconData in storedBeacons {
                let beacon = NSKeyedUnarchiver.unarchiveObject(with: (beaconData as! NSData) as Data) as! iBeaconItem
                iBeacons.append(beacon)
            }
        }
    }
    
    func readSharedCSV(completionHandler: @escaping (() -> ())) {
        
        iBeacons.removeAll()
        
        if defaults?.data(forKey: Keys.spreadsheetFile) != nil {
            
            tableView.isHidden = true
            activityIndicator.startAnimating()
            emptyStateLabel.alpha = 0
            emptyStateIcon.alpha = 0
            
            let data = defaults?.data(forKey: Keys.spreadsheetFile)
            let dataString = String(data: data!, encoding: .utf8)
            
            let cleanString = dataString?.replacingOccurrences(of: "\r", with: "\n")
            let csv = CSVParser(with: cleanString!)
            
            let csvCount = csv.keyedRows!.count
            var beaconCounter = 0
            
            for object in csv.keyedRows! {
                
                var newBeacon: iBeaconItem?
                
                //Need to handle nils, for when the spreadsheet has blank spots
                let name            = object["Beacon Name"]
                let uuid            = object["UUID"]?.convertToUUID()
                let major           = object["Major"]?.convertToMajorValue()
                let minor           = object["Minor"]?.convertToMinorValue()
                let actionURL       = object["Action URL"]
                let actionURLName   = object["Action URL Name"]
                let actionType      = object["Action Type"]
                let type            = object["Type"]
                let mapURL          = object["Map URL"]
                let color           = Colors.white
                
                if let imageURL = object["Image URL"] {
                    
                    let convertedURL = NSURL(string: imageURL)
                    let networking = Networking(url: convertedURL!)
                    
                    networking.downloadImage(completion: { (imageData) in
                        
                        let itemImage = UIImage(data: imageData)
                        
                        newBeacon = iBeaconItem(name: name!, uuid: uuid!, majorValue: major, minorValue: minor, itemImage: itemImage!, actionURL: actionURL!, actionURLName: actionURLName!, actionType: actionType!, type: type!, mapURL: mapURL!, color: color)
                        
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
    
    func readSharedCSVWithClosure() {
        
        readSharedCSV { () -> () in
            
            self.defaults?.set(false, forKey: Keys.isNewSharedSpreadsheet)
            self.persistBeacons()
            self.setupBeaconRegions()
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func filterButtonPressed(_ sender: UIBarButtonItem) {
        isFiltered = isFiltered ? false : true
//        filterBarButton.setBackgroundImage(UIImage(named: "filter-filled"), for: .normal, barMetrics: .default)
//        filterBarButton.setBackButtonBackgroundImage(UIImage(named: "filter-filled"), for: .normal, barMetrics: .default)
        tableView.reloadData()
    }
    
    @IBAction func importButtonPressed(_ sender: UIBarButtonItem) {
        
        let importMenu = UIDocumentMenuViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
        importMenu.delegate = self
        importMenu.addOption(withTitle: "CSV From FileMaker", image: UIImage(named: "filemaker-line-logo")?.withRenderingMode(.alwaysOriginal), order: .first, handler: {
            self.openFileMaker()
        })
        self.present(importMenu, animated: true, completion: nil)
    }
    
    func openFileMaker() {
        
        let fileMakerURL = "fmp://$"
        let url = URL(string: fileMakerURL)
        
        DispatchQueue.main.async(execute: {
            UIApplication.shared.openURL(url!)
        })
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        clearSpreadsheetCache()
        var csvString: String?
        
        do {
            csvString = try String(contentsOf: url)
        } catch {
            print("No URL found at document picked")
        }
        
        let spreadsheetData = csvString?.data(using: .utf8)
        saveSpreadsheet(data: spreadsheetData! as NSData, completionHandler: {
            self.readSharedCSVWithClosure()
        })
    }
    
    func saveSpreadsheet(data: NSData, completionHandler: @escaping (() -> ())) {
        defaults?.set(data, forKey: Keys.spreadsheetFile)
        defaults?.set(true, forKey: Keys.isNewSharedSpreadsheet)
        completionHandler()
    }
    
    func clearSpreadsheetCache() {
        defaults?.set(nil, forKey: Keys.spreadsheetFile)
    }
    
    @IBAction func cancel(_ segue: UIStoryboardSegue) {
        // Do nothing
    }
    
    //MARK: - TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let beaconArray = isFiltered ? filteredBeacons.count : iBeacons.count
        return beaconArray
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cells.beaconCell, for: indexPath) as! BeaconCell
        let beacon = isFiltered ? filteredBeacons[(indexPath as NSIndexPath).row] : iBeacons[(indexPath as NSIndexPath).row]
        
        cell.beacon = beacon
        
        cell.nameLabel!.text = beacon.name
        cell.typeLabel!.text = "Type: \(beacon.type)"
        cell.actionURLButton.setTitle(beacon.actionURLName, for: .normal)
        cell.beaconImage.image = beacon.itemImage
        
        cell.actionURLButton.tag = indexPath.row
        cell.actionURLButton.addTarget(self, action: #selector(BeaconListScreen.actionURLPressed(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    //  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //    let cell = tableView.dequeueReusableCell(withIdentifier: Cells.beaconCell, for: indexPath) as! BeaconCell
    //
    //    if cell.distanceLabel.text == "Not Found" {
    //      return 0
    //    } else {
    //      return 120
    //    }
    //  }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let beaconToRemove = iBeacons[(indexPath as NSIndexPath).row] as iBeaconItem
            stopRangingBeacon(beaconToRemove)
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
        
        switch selectedBeacon.actionType {
            
        case "Website":
            
            let url = URL(string: (selectedBeacon.actionURL))
            let vc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
            present(vc, animated: true, completion: nil)
            
        case "FileMaker":
            
            let urlFromBeacon = selectedBeacon.actionURL
            
            if let url = URL(string: urlFromBeacon) {
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.openURL(url)
                })
            }
            
        case "PhoneNumber":
            
            let alert = UIAlertController(title: "Call \(selectedBeacon.actionURL)?", message: nil, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in }
            
            let callAction = UIAlertAction(title: "Call", style: .default) { (action) in
                UIApplication.shared.openURL(NSURL(string: "tel://\(selectedBeacon.actionURL)")! as URL)
            }
            
            alert.addAction(callAction)
            alert.addAction(cancelAction)
            self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    //MARK: - Beacon Ranging
    func startRangingBeacon(_ beacon: iBeaconItem) {
        let beaconRegion = beaconRegionWithItem(beacon)
        locationManager.startRangingBeacons(in: beaconRegion)
    }
    
    func stopRangingBeacon(_ beacon: iBeaconItem) {
        let beaconRegion = beaconRegionWithItem(beacon)
        locationManager.stopRangingBeacons(in: beaconRegion)
    }
    
    func beaconRegionWithItem(_ beacon: iBeaconItem) -> CLBeaconRegion {
        let beaconRegion = CLBeaconRegion(proximityUUID: beacon.uuid as UUID, identifier: beacon.name)
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
        
//        var tempArray: [iBeaconItem] = []
        
        if isFiltered {
            
            for beacon in beacons {
                
                for iBeacon in iBeacons {
                    
                    if iBeacon == beacon {
                        iBeacon.lastSeenBeacon = beacon
                        
                        if filteredBeacons.contains(iBeacon) == false {
                            filteredBeacons.append(iBeacon)
                            print(filteredBeacons.count)
                            tableView.reloadData()
                        }
                    }
                }
            }
            
//            tempArray.removeAll()
            
//            for beacon in beacons {
//                
//                for iBeacon in iBeacons {
//                    
//                    if iBeacon == beacon {
//                        iBeacon.lastSeenBeacon = beacon
//                        tempArray.append(iBeacon)
//                    }
//                }
//            }
            
//            tempArray = loopThroughDiscoveredBeacons(discoveredBeacons: beacons, beaconList: iBeacons)
            
            
            
            // Compare a temp array with filtered array. If different, then reload data.
            // This is working fine until I dynamically add a new beacon
            
//            tempArray.sort(by: { $0.name < $1.name })
//            
//            if tempArray.count == 0 {
//                print("tempArray count = 0")
//                
//            } else if tempArray == filteredBeacons {
//                print("No New Beacons Discovered")
//            } else {
//                filteredBeacons = tempArray
//                print("New Beacon!")
//                print("tempArray count = \(tempArray.count)")
//                tableView.reloadData()
//                // check memory performance when working
//            }
            
        } else {
            
            for beacon in beacons {
                
                for iBeacon in iBeacons {
                    
                    if iBeacon == beacon {
                        iBeacon.lastSeenBeacon = beacon
                    }
                }
            }
        }
    }
    
    func loopThroughDiscoveredBeacons(discoveredBeacons: [CLBeacon], beaconList: [iBeaconItem]) -> [iBeaconItem] {
        
        var tempArray: [iBeaconItem] = []
        
        for beacon in discoveredBeacons {
            
            for iBeacon in beaconList {
                
                if iBeacon == beacon {
                    iBeacon.lastSeenBeacon = beacon
                    tempArray.append(iBeacon)
                }
            }
        }
        
        return tempArray
    }
    
    func changeFilterButtonImage() {
        
        let image = isFiltered ? UIImage(named: "filter-filled") : UIImage(named: "filter")
        
        let button = UIButton.init(type: .custom)
        button.setImage(image, for: .normal)
        button.addTarget(self, action:#selector(BeaconListScreen.filterButtonPressed(_:)), for: .touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem.init(customView: button)
        navigationItem.leftBarButtonItem = barButton
    }
}
