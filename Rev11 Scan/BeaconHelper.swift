//
//  BeaconHelper.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 8/25/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class BeaconHelper {

  class func intForProximity(proximity: CLProximity) -> Int {

    switch proximity {
      
    case .Immediate:
      return 0
    case .Near:
      return 1
    case .Far:
      return 2
    case .Unknown:
      return 3
    }
  }
  
}
