//
//  EstimoteCell.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/26/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class EstimoteCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  @IBOutlet weak var telemetryOneDataLabel: UILabel!
  @IBOutlet weak var telemetryTwoDataLabel: UILabel!
  @IBOutlet weak var telemetryThreeDataLabel: UILabel!


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  var beacon: EstimoteBeacon? = nil {

    willSet {
      if let thisBeacon = beacon {
        thisBeacon.removeObserver(self, forKeyPath: "lastSeenEstimote")
      }
    }
    didSet {
      beacon?.addObserver(self, forKeyPath: "lastSeenEstimote", options: .New, context: nil)
      uuidLabel!.text = beacon?.uuid!.UUIDString
      nameLabel.text = beacon?.name

      if beacon != nil {
        setProximityProperties()
      }
    }
  }

  deinit {
    beacon?.removeObserver(self, forKeyPath: "lastSeenEstimote")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    beacon = nil
  }

  func nameForProximity(proximity: CLProximity) -> String {

    switch proximity {

    case .Unknown:
      beacon!.color = Colors.white
      return "Unknown"

    case .Immediate:
      beacon!.color = Colors.green
      return "Immediate: "

    case .Near:
      beacon!.color = Colors.yellow
      return "Near: "

    case .Far:
      beacon!.color = Colors.red
      return "Far: "
    }
  }

  func setProximityProperties() {

    let proximity = nameForProximity((beacon?.lastSeenEstimote!.proximity)!)
    let accuracy = NSString(format: "%.2f", (beacon?.lastSeenEstimote!.accuracy)!)
    locationLabel.text = "\(proximity) (approx. \(accuracy) meters)"
    self.backgroundColor = beacon?.color
  }
  
}
