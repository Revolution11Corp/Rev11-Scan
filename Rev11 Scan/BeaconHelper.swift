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

  class func intForProximity(_ proximity: CLProximity) -> Int {

    switch proximity {
      
    case .immediate:
      return 0
    case .near:
      return 1
    case .far:
      return 2
    case .unknown:
      return 3
    }
  }
  
}
