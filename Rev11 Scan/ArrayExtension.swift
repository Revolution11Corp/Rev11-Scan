//
//  ArrayExtension.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 10/31/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation

extension Array {

  func filterDuplicates( includeElement: @escaping (_ lhs:Element, _ rhs:Element) -> Bool) -> [Element]{
    var results = [Element]()

    forEach { (element) in
      let existingElements = results.filter {
        return includeElement(element, $0)
      }
      if existingElements.count == 0 {
        results.append(element)
      }
    }

    return results
  }
}
