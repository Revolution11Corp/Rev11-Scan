//
//  QueryURL.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 8/29/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation

// MARK: String
extension String {

  var toQueryDictionary: [String : String] {
    var result: [String : String] = [String : String]()

    let pairs: [String] = self.components(separatedBy: "&")

    for pair in pairs {
      var comps: [String] = pair.components(separatedBy: "=")
      if comps.count >= 2 {
        let key = comps[0]
        let value = comps.dropFirst().joined(separator: "=")

        result[key.queryDecode] = value.queryDecode
      }
    }
    return result
  }

  var queryEncodeRFC3986: String {

    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="

    var allowedCharacterSet = NSCharacterSet.urlQueryAllowed
    allowedCharacterSet.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)

    return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
  }

  var queryEncode: String {
    return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
  }

  var queryDecode: String {
    return self.removingPercentEncoding ?? self
  }

}

// MARK: Dictionary
extension Dictionary {

  var queryString: String {
    var parts = [String]()
    for (key, value) in self {
      let keyString = "\(key)".queryEncodeRFC3986
      let valueString = "\(value)".queryEncodeRFC3986
      let query = "\(keyString)=\(valueString)"
      parts.append(query)
    }
    return parts.joined(separator: "&") as String
  }

  func join(other: Dictionary) -> Dictionary {
    var joinedDictionary = Dictionary()

    for (key, value) in self {
      joinedDictionary.updateValue(value, forKey: key)
    }

    for (key, value) in other {
      joinedDictionary.updateValue(value, forKey: key)
    }

    return joinedDictionary
  }

  init(_ pairs: [Element]) {
    self.init()
    for (k, v) in pairs {
      self[k] = v
    }
  }

}

func +<K, V> (left: [K : V], right: [K : V]) -> [K : V] { return left.join(other: right) }


// MARK: NSURLComponents
extension NSURLComponents {

  var queryDictionary: [String: String] {
    get {
      guard let query = self.query else {
        return [:]
      }
      return query.toQueryDictionary
    }
    set {
      if newValue.isEmpty {
        self.query = nil
      } else {
        self.percentEncodedQuery = newValue.queryString
      }
    }
  }

  func addToQuery(add: String) {
    if let query = self.percentEncodedQuery {
      self.percentEncodedQuery = query + "&" + add
    } else {
      self.percentEncodedQuery = add
    }
  }

}

func &= (left: NSURLComponents, right: String) { left.addToQuery(add: right) }
