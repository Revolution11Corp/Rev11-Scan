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
import MapKit

class BeaconListScreen: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentMenuDelegate, UIDocumentPickerDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateIcon: UIImageView!
    @IBOutlet weak var emptyStateLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var permissionsView: UIView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var hideMapButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    
    let locationManager = CLLocationManager()
    let defaults = UserDefaults(suiteName: Keys.suiteName)
    var iBeacons: [iBeaconItem] = []
    var filteredBeacons: [iBeaconItem] = []
    
    var importButton: UIBarButtonItem!
    var mapButton: UIBarButtonItem!
    
    var transparencyView: UIView!
    var uuidRegex = try! NSRegularExpression(pattern: "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", options: .caseInsensitive)
    
    var isFiltered = false
    var isShowingMap = true
    
    var cache: NSCache<AnyObject, AnyObject>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRightNavButtons()
        transparencyView = createTransparencyView()
        NavBarSetup.showLogoInNavBar(self.navigationController!, navItem: self.navigationItem)
        changeFilterButtonImage()
        setupMapView()
        cache = NSCache()
        tableView.hideExcessSeparatorLines()
        tableContainerView.setShadow(width: 0, height: -6)
        locationManager.delegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(BeaconListScreen.reloadViewFromBackground), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NetworkManager.shared.authenticateDemoUser { (token, error) in
            
            if let token = token {
                print("Token = \(token)")
                
                NetworkManager.shared.getBeaconEntries(token: token, completed: { (beacons, error) in
                    if let beacons = beacons {
                        self.iBeacons.removeAll()
                        
                        //TODO: Sean's test beacon. Remove when confirmed to be working
//                        let newBeacon = iBeaconItem(data: ["UUID": "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6",
//                                                           "name": "Sean Test", "Major": "3426", "Minor": "1111"])
//                        self.iBeacons.append(newBeacon)
                        self.iBeacons.append(contentsOf: beacons)
                        self.tableView.reloadDataOnMainThread()
                        
                        DispatchQueue.main.async {
                            self.createMapAnnotations(beacons: self.iBeacons)
                            self.setupBeaconRegions()
                        }
                    }
                })
                
            } else {
                print("Noken = nil")
            }
        }
    }
    
    @objc func reloadViewFromBackground() {
        viewWillAppear(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkForExistingCSV()
        
        if Constants.defaults.bool(forKey: Keys.hasViewedPermissions) != true {
            showPermissionsView(bool: true)
        }
    }
    
    func setupMapView() {
        
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
        
        let noLocation = CLLocationCoordinate2D()
        let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 2000, 2000)
        mapView.setRegion(viewRegion, animated: false)
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func createMapAnnotations(beacons: [iBeaconItem]) {
        
        for beacon in beacons {
            
            let lat  = Double(beacon.latitude.removeWhitespaces()) ??  0.00 //TODO: THis has bad data incoming, which requires removal of whitespace
            let long = Double(beacon.longitude.removeWhitespaces()) ?? 0.00
            
            let beaconAnnotation        = MKPointAnnotation()
            beaconAnnotation.coordinate = CLLocationCoordinate2DMake(lat, long)
            beaconAnnotation.title      = beacon.name
            mapView.addAnnotation(beaconAnnotation)
        }
    }
    
    func checkForExistingCSV() {
        
        if UserDefaults.standard.array(forKey: BeaconProperties.storedBeaconArrayKey) != nil {
            
            if defaults?.bool(forKey: Keys.isNewSharedSpreadsheet) == false {
                iBeacons = Persistence.loadBeacons()
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
        let beaconRegions: [iBeaconItem] = iBeacons.filterDuplicates { $0.UUID == $1.UUID && $0.UUID == $1.UUID }
        
        for beacon in beaconRegions {
            startRangingBeacon(beacon)
        }
    }
    
    func readSharedCSV(completionHandler: @escaping (() -> ())) {
        
        //TODO: Update Read CSV with new iBeaconItem
        
//        iBeacons.removeAll()
//        filteredBeacons.removeAll()
//
//        if defaults?.data(forKey: Keys.spreadsheetFile) != nil {
//
//            showEmptyState(bool: true)
//            activityIndicator.startAnimating()
//            emptyStateLabel.alpha = 0
//            emptyStateIcon.alpha = 0
//
//            let data = defaults?.data(forKey: Keys.spreadsheetFile)
//            let dataString = String(data: data!, encoding: .utf8)
//
//            let cleanString = dataString?.replacingOccurrences(of: "\r", with: "\n")
//            let csv = CSVParser(with: cleanString!)
//
//            let csvCount = csv.keyedRows!.count
//            var beaconCounter = 0
//
//            for object in csv.keyedRows! {
//
//                var newBeacon: iBeaconItem?
//
//                //Need to handle nils, for when the spreadsheet has blank spots
//                let name            = object["Beacon Name"]
//                let uuid            = object["UUID"]?.convertToUUID()
//                let major           = object["Major"]?.convertToMajorValue()
//                let minor           = object["Minor"]?.convertToMinorValue()
//                let actionURL       = object["Action URL"]
//                let actionURLName   = object["Action URL Name"]
//                let actionType      = object["Action Type"]
//                let type            = object["Type"]
//                let mapURL          = object["Map URL"]
//                let colorR          = CGFloat(truncating: NumberFormatter().number(from: object["ColorR"]!)!)
//                let colorG          = CGFloat(truncating: NumberFormatter().number(from: object["ColorG"]!)!)
//                let colorB          = CGFloat(truncating: NumberFormatter().number(from: object["ColorB"]!)!)
//
//                let color = UIColor(red: colorR/255.0, green: colorG/255.0, blue: colorB/255.0, alpha: 1.0)
//                let backgroundColor = Colors.white
//
//                if let imageURL = object["Image URL"] {
//
//                    let convertedURL = NSURL(string: imageURL)
//                    let networking = Networking(url: convertedURL!)
//
//                    networking.downloadImage(completion: { (imageData) in
//
//                        let itemImage = UIImage(data: imageData)
//
//                        newBeacon = iBeaconItem(name: name!, uuid: uuid!, majorValue: major, minorValue: minor, itemImage: itemImage!, actionURL: actionURL!, actionURLName: actionURLName!, actionType: actionType!, type: type!, mapURL: mapURL!, color: color, backgroundColor: backgroundColor)
//
//                        self.iBeacons.append(newBeacon!)
//
//                        beaconCounter += 1
//
//                        if beaconCounter == csvCount {
//
//                            completionHandler()
//                        }
//                    })
//                }
//            }
//        } else {
//            showEmptyState(bool: true)
//        }
    }
    
    func readSharedCSVWithClosure() {
        
        readSharedCSV { () -> () in
            
            self.defaults?.set(false, forKey: Keys.isNewSharedSpreadsheet)
            self.persistBeacons()
            self.setupBeaconRegions()
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.showEmptyState(bool: false)
                self.tableView.reloadData()
            }
        }
    }
    
    func showEmptyState(bool: Bool) {
        mapView.alpha = bool ? 0.0 : 1.0
        tableContainerView.alpha = bool ? 0.0 : 1.0
    }
    
    @objc func filterButtonPressed() {
        isFiltered = isFiltered ? false : true
        changeFilterButtonImage()
        tableView.reloadData()
    }
    
    @objc func importButtonPressed(_ sender: UIBarButtonItem) {
        
        let importMenu = UIDocumentMenuViewController(documentTypes: [kUTTypeCommaSeparatedText as String], in: .import)
        importMenu.delegate = self
        importMenu.addOption(withTitle: "CSV From FileMaker", image: UIImage(named: "filemaker-line-logo")?.withRenderingMode(.alwaysOriginal), order: .first, handler: {
            self.openFileMaker()
        })
        
        modalPresentationStyle = .popover
        importMenu.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        
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
        
        cell.actionURLButton.tag = indexPath.row
        cell.setBeaconCell(beacon: beacon)
        
        let ownerImageKey   = beacon.ownerLogoURL as AnyObject
        let objectImageKey  = beacon.imageURL as AnyObject
        
        if cache.object(forKey: ownerImageKey) != nil {
            cell.ownerLogoImageView.image = cache.object(forKey: ownerImageKey) as? UIImage
            
        } else {
            
            NetworkManager.shared.downloadImage(url: beacon.ownerLogoURL, completion: { (imageData) in
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.ownerLogoImageView.image = image
                        self.cache.setObject(image, forKey: ownerImageKey)
                    }
                } else {
                    //TODO: Set placeholder image
                }
            })
        }
        
        if cache.object(forKey: objectImageKey) != nil {
            cell.itemImageView.image = cache.object(forKey: objectImageKey) as? UIImage
            
        } else {
            
            NetworkManager.shared.downloadImage(url: beacon.imageURL, completion: { (imageData) in
                
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        cell.itemImageView.image = image
                        self.cache.setObject(image, forKey: objectImageKey)
                    }
                } else {
                    //TODO: Set placeholder image
                }
            })
        }
        
        return cell
    }
    
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
        let uuid = beacon.UUID.uuidString
        let detailMessage = "UUID: \(uuid)\nMajor: \(beacon.major)\nMinor: \(beacon.minor)"
        let detailAlert = UIAlertController(title: "Beacon Info", message: detailMessage, preferredStyle: .alert)
        detailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(detailAlert, animated: true, completion: nil)
    }
    
    @objc func actionURLPressed(sender: UIButton) {
        
        let beaconRow = sender.tag
        let selectedBeacon = iBeacons[beaconRow]
        
        switch selectedBeacon.actionURLName {
            
        case "Website":
            
            let url = URL(string: (selectedBeacon.actionURL))
            let vc = SFSafariViewController(url: url!, entersReaderIfAvailable: true)
            present(vc, animated: true, completion: nil)
            
        case "FileMaker":
            
            let urlFromBeacon = selectedBeacon.actionURL!
            
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
        let beaconRegion = CLBeaconRegion(proximityUUID: beacon.UUID as UUID, identifier: beacon.name)
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
    
    func changeFilterButtonImage() {
        
        navigationItem.leftBarButtonItem = nil
        
        let image = isFiltered ? #imageLiteral(resourceName: "filter-filled") : #imageLiteral(resourceName: "filter")
        
        let button = UIButton.init(type: .custom)
        button.setImage(image, for: .normal)
        button.removeTarget(nil, action: nil, for: .allEvents)
        button.addTarget(self, action:#selector(BeaconListScreen.filterButtonPressed), for: .touchUpInside)
        button.frame = CGRect.init(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem.init(customView: button)
        navigationItem.leftBarButtonItem = barButton
    }
    
    func setupRightNavButtons() {
        
        importButton = UIBarButtonItem(image: #imageLiteral(resourceName: "download-icloud"),  style: .plain, target: self, action: #selector(BeaconListScreen.importButtonPressed(_:)))
        
        navigationItem.rightBarButtonItems = [importButton]
    }
    
    @IBAction func hideMapButtonPressed(_ sender: UIButton) {
        
        let multiplier: CGFloat = isShowingMap ? 0.001 : 0.4
        mapViewHeightConstraint = mapViewHeightConstraint.setMultiplier(multiplier: multiplier)
        
        let flipped = self.isShowingMap ? CGAffineTransform(scaleX: 1, y: -1) : CGAffineTransform(scaleX: -1, y: 1)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.hideMapButton.imageView?.layer.setAffineTransform(flipped)
            self.view.layoutIfNeeded()
        })
        
        isShowingMap = isShowingMap ? false : true
    }
}

extension BeaconListScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation: CLLocation = locations[0]
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
    }
}
