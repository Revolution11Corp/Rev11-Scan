//
//  URLParameter.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/13/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class URLParameter {

  static let sharedInstance = URLParameter()

  var baseURL: String?
  var isFromFileMaker: Bool?

  fileprivate init() { }
  
}
