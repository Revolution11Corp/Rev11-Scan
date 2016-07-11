//
//  BeaconCell.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

class BeaconCell: UITableViewCell {

  @IBOutlet weak var beaconTypeImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var tempLabel: UILabel!

  func setupTLM() {

    let estimoteDeviceManager = ESTDeviceManager()

    let temperatureNotification = ESTTelemetryNotificationTemperature { (temperature: ESTTelemetryInfoTemperature) in

      print("Current temperature: \(temperature.temperatureInCelsius) C")

      self.tempLabel.text = "\(temperature.temperatureInCelsius) C"
    }

//    let temperatureNotification: ESTTelemetryNotificationTemperature = ESTTelemetryNotificationTemperature(notificationBlock: {(temperature: ESTTelemetryInfoTemperature) -> Void in
//
//
//
//
//    })

    estimoteDeviceManager.registerForTelemetryNotification(temperatureNotification)

  }


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  var beacon: iBeaconItem? = nil {

    willSet {
      if let thisBeacon = beacon {
        thisBeacon.removeObserver(self, forKeyPath: "lastSeenBeacon")
      }
    }
    didSet {
      beacon?.addObserver(self, forKeyPath: "lastSeenBeacon", options: .New, context: nil)
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

  func nameForProximity(proximity: CLProximity) -> String {

    switch proximity {

    case .Unknown:
      return "Unknown"

    case .Immediate:
      return "Immediate"

    case .Near:
      return "Near"

    case .Far:
      return "Far"
    }
  }

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

    if let aBeacon = object as? iBeaconItem {

      if aBeacon == beacon && keyPath == "lastSeenBeacon" {

        let proximity = nameForProximity(aBeacon.lastSeenBeacon!.proximity)
        let accuracy = NSString(format: "%.2f", aBeacon.lastSeenBeacon!.accuracy)
        locationLabel!.text = "Location: \(proximity) (approx. \(accuracy)m)"

        setupTLM()
      }
    }
  }
}
