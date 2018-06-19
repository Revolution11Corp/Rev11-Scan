//
//  BeaconCell.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation
import SafariServices
import MapKit

protocol BeaconCellDelegate {
    func didTapActionButton(atRow: Int)
}

class BeaconCell: UITableViewCell {
    
    @IBOutlet weak var ownerLogoImageView: UIImageView!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var itemMapView: MKMapView!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var actionURLButton: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionURLButton.roundCorners()
    }
    
    var row: Int!
    var delegate: BeaconCellDelegate!
    
    var beacon: iBeaconItem? = nil {
        willSet {
            if let thisBeacon = beacon {
                thisBeacon.removeObserver(self, forKeyPath: Keys.lastSeenBeacon)
            }
        }
        didSet {
            self.beacon?.addObserver(self, forKeyPath: Keys.lastSeenBeacon, options: .new, context: nil)
        }
    }
    
    
    deinit {
        beacon?.removeObserver(self, forKeyPath: Keys.lastSeenBeacon)
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        beacon = nil
        resetCellUI()
    }
    
    func setBeaconCell(beacon: iBeaconItem) {
        self.beacon = beacon
    
        nameLabel!.text = beacon.name
        actionURLButton.setTitle(beacon.actionURLName, for: .normal)
        setupMapView(beacon: beacon)
        streetAddressLabel.text = beacon.streetAddress
        cityLabel.text = "\(beacon.city!), \(beacon.state!)  \(beacon.zipcode!)"
        
        actionURLButton.alpha     = Reachability.isConnectedToNetwork() ? 1.0 : 0.15
        actionURLButton.isEnabled = Reachability.isConnectedToNetwork()
    }
    
    func setupMapView(beacon: iBeaconItem) {
        
        let lat  = Double(beacon.latitude.removeWhitespaces()) ?? 0.00 //TODO: THis has bad data incoming, which requires removal of whitespace
        let long = Double(beacon.longitude.removeWhitespaces()) ?? 0.00
        
        let regionRadius: CLLocationDistance = 1000
        let beaconLocation = CLLocation(latitude: lat, longitude: long)

        let coordinateRegion = MKCoordinateRegionMakeWithDistance(beaconLocation.coordinate, regionRadius, regionRadius)
        itemMapView.setRegion(coordinateRegion, animated: false)
        
        let beaconAnnotation = MKPointAnnotation()
        beaconAnnotation.coordinate = CLLocationCoordinate2DMake(lat, long)
        beaconAnnotation.title = beacon.name
        itemMapView.addAnnotation(beaconAnnotation)
    }
    
    
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        delegate.didTapActionButton(atRow: row)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
        if let aBeacon = object as? iBeaconItem {
            if aBeacon == beacon && keyPath == Keys.lastSeenBeacon {
                let proximity = nameForProximity(aBeacon.lastSeenBeacon!.proximity)
                locationLabel.text = proximity == "Unknown" ? "--" : "\(proximity)"
            }
        }
    }
    
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        
        switch proximity {
            
        case .unknown:
            updateCellUI(Colors.lightGrey, textColor: Colors.darkGrey, alpha: 1.0, distanceValue: "Weak Signal")
            return "Unknown"
            
        case .immediate:
            updateCellUI(Colors.white, textColor: Colors.green, alpha: 1.0, distanceValue: "~ < 1 meter")
            return "Close"
            
        case .near:
            updateCellUI(Colors.white, textColor: Colors.yellow, alpha: 1.0, distanceValue: "~ 1-3 meters")
            return "Near"
            
        case .far:
            updateCellUI(Colors.white, textColor: Colors.red, alpha: 1.0, distanceValue: "~ 3+ meters")
            return "Far"
        }
    }
    
    
    func updateCellUI(_ backgroundColor: UIColor, textColor: UIColor, alpha: CGFloat, distanceValue: String) {
        locationLabel.textColor = textColor
        distanceLabel.text = distanceValue
        contentView.alpha = alpha
    }
    
    
    func resetCellUI() {
        locationLabel.text = "--"
        distanceLabel.text = "Not Found"
        locationLabel.textColor = Colors.darkGrey
        ownerLogoImageView.image = nil
        itemImageView.image = nil
        itemMapView.removeAnnotations(itemMapView.annotations)
    }
}
