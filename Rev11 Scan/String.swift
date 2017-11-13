//
//  String.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 9/6/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import CoreLocation

extension String {
    
    var isEmptyOrWhitespace: Bool {
        return isEmpty ? true : trimmingCharacters(in: .whitespaces) == ""
    }
    
    var isNotEmptyOrWhitespace: Bool {
        return !isEmptyOrWhitespace
    }
    
    func convertToUUID() -> UUID {
        if let convertedString = UUID(uuidString: self) {
            return convertedString
        } else {
            //TODO: This is temporary to get the app running. Figure out a better way to handle a bad UUID input
            let defaultFailureUUID = UUID(uuidString: "B9407F30-F5F8-466E-AFF9-25556B57FE6D")!
            return defaultFailureUUID
        }
        
    }
    
    func removeWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    func convertToMajorValue() -> CLBeaconMajorValue {
        let convertedToInt = Int(self)
        let convertedToMajorValue = CLBeaconMajorValue(convertedToInt!)
        return convertedToMajorValue
    }
    
    func convertToMinorValue() -> CLBeaconMinorValue {
        let convertedToInt = Int(self)
        let convertedToMinorValue = CLBeaconMinorValue(convertedToInt!)
        return convertedToMinorValue
    }
    
}
