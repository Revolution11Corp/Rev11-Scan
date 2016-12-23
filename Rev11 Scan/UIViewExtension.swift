//
//  UIViewExtension.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 12/23/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func setShadow(width: CGFloat, height: CGFloat) {
        layer.shadowColor = Colors.black.cgColor
        layer.shadowOffset = CGSize(width: width, height: height)
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.35
//        layer.masksToBounds = false
        
//        clipsToBounds = false
        
    }
}
