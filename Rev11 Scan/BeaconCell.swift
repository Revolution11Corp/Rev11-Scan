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

class BeaconCell: UITableViewCell {
    
    @IBOutlet weak var beaconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var actionURLButton: UIButton!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        actionURLButton.roundCorners()
        beaconImage.roundCorners()
    }
    
    
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
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let aBeacon = object as? iBeaconItem {
            if aBeacon == beacon && keyPath == Keys.lastSeenBeacon {
                
                let proximity = nameForProximity(aBeacon.lastSeenBeacon!.proximity)
                locationLabel.text = proximity == "Unknown" ? "--" : "\(proximity)"
//                backgroundColor = beacon?.backgroundColor
            }
        }
    }
    
    
    func nameForProximity(_ proximity: CLProximity) -> String {
        
        switch proximity {
            
        case .unknown:
            updateCellUI(Colors.lightGrey, textColor: Colors.darkGrey, alpha: 0.5, distanceValue: "Weak Signal")
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
//        beacon!.backgroundColor = backgroundColor
        locationLabel.textColor = textColor
        distanceLabel.text = distanceValue
        contentView.alpha = alpha
    }
    
    
    func resetCellUI() {
        locationLabel.text = "--"
        distanceLabel.text = "Not Found"
        locationLabel.textColor = Colors.darkGrey
        backgroundColor = Colors.lightGrey
        contentView.alpha = 0.5
    }
}
