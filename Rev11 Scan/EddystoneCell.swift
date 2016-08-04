//
//  EddystoneCell.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/24/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
//import CoreLocation

class EddystoneCell: UITableViewCell {

  @IBOutlet weak var beaconTypeImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

