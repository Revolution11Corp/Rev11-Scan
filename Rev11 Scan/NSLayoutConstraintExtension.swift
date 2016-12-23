//
//  NSLayoutConstraintExtension.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 12/20/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {

    func setMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(item: firstItem, attribute: firstAttribute, relatedBy: relation, toItem: secondItem, attribute: secondAttribute, multiplier: multiplier, constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
    }
}
