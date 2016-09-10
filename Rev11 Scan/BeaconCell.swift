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

  @IBOutlet weak var beaconTypeImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var actionURLButton: UIButton!


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  var beacon: iBeaconItem? = nil {

    willSet {
      if let thisBeacon = beacon {
        thisBeacon.removeObserver(self, forKeyPath: "lastSeenBeacon")
      }
    }
    didSet {
      beacon?.addObserver(self, forKeyPath: "lastSeenBeacon", options: .new, context: nil)
      nameLabel!.text = beacon?.name
    }
  }

  deinit {
    beacon?.removeObserver(self, forKeyPath: "lastSeenBeacon")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    beacon = nil
  }

  func nameForProximity(_ proximity: CLProximity) -> String {

    switch proximity {

    case .unknown:
      beacon!.color = Colors.white
      return "Unknown"

    case .immediate:
      beacon!.color = Colors.green
      return "Immediate"

    case .near:
      beacon!.color = Colors.yellow
      return "Near"

    case .far:
      beacon!.color = Colors.red
      return "Far"
    }
  }

  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [String : Any]?, context: UnsafeMutableRawPointer?) {

    if let aBeacon = object as? iBeaconItem {

      if aBeacon == beacon && keyPath == "lastSeenBeacon" {

        let proximity = nameForProximity(aBeacon.lastSeenBeacon!.proximity)
        let accuracy = NSString(format: "%.2f", aBeacon.lastSeenBeacon!.accuracy)
        locationLabel!.text = "Location: \(proximity) (approx. \(accuracy)m)"
        self.backgroundColor = beacon?.color
      }
    }
  }

}
