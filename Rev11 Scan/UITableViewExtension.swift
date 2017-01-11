//
//  UITableViewExtension.swift
//  Rev11 Scan
//
//  Created by Sean Allen on 1/10/17.
//  Copyright © 2017 Revolution11. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func hideExcessSeparatorLines() {
        tableFooterView = UIView(frame: CGRect.zero)
    }
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
