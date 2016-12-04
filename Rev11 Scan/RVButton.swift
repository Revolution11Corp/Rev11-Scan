//
//  RVButton.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 12/4/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class RVButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init( coder: aDecoder )
        setUpButton()
    }
    
    func setUpButton() {
        self.layoutIfNeeded()
        self.layer.cornerRadius = self.frame.size.height/2
    }
}

