//
//  RVTextField.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 12/4/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class RVTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpTextField()
    }
    
    func setUpTextField() {
        self.layoutIfNeeded()
        self.layer.cornerRadius = 10
        layer.borderWidth = 1.5
        layer.borderColor = Colors.lightGrey.cgColor
    }
}
