//
//  EstimoteBeacon.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/31/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation


class EstimoteBeacon: NSObject {

  let name: String?
  let uuid: UUID?
  let majorValue: NSNumber?
  let minorValue: NSNumber?
  let proximity: Int?

  var color: UIColor?

  dynamic var lastSeenEstimote: CLBeacon?

  init(name: String, uuid: UUID, majorValue: NSNumber?, minorValue: NSNumber?, proximity: Int, color: UIColor) {
    self.name = name
    self.uuid = uuid
    self.majorValue = majorValue!
    self.minorValue = minorValue!
    self.proximity = proximity
    self.color = Colors.white
    super.init()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}
