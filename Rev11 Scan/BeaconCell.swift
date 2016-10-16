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


  override func awakeFromNib() {
    super.awakeFromNib()
    actionURLButton.layoutIfNeeded()
    actionURLButton.layer.cornerRadius = actionURLButton.frame.size.height/2
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
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
  }

  func nameForProximity(_ proximity: CLProximity) -> String {

    switch proximity {

    case .unknown:
      beacon!.color = Colors.lightGrey
      return "Unknown"

    case .immediate:
      beacon!.color = Colors.white
      return "Immediate"

    case .near:
      beacon!.color = Colors.white
      return "Near"

    case .far:
      beacon!.color = Colors.white
      return "Far"
    }
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

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
