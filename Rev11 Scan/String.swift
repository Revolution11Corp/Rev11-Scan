//
//  String.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 9/6/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation

extension String {

  var isEmptyOrWhitespace: Bool {
    return characters.isEmpty ? true : trimmingCharacters(in: .whitespaces) == ""
  }

  var isNotEmptyOrWhitespace: Bool {
    return !isEmptyOrWhitespace
  }
  
}
