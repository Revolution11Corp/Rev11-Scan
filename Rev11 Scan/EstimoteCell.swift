//
//  EstimoteCell.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 7/26/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit

class EstimoteCell: UITableViewCell {

  @IBOutlet weak var estimoteImage: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var uuidLabel: UILabel!
  @IBOutlet weak var locationLabel: UILabel!

  @IBOutlet weak var telemetryOneDataLabel: UILabel!
  @IBOutlet weak var telemetryTwoDataLabel: UILabel!
  @IBOutlet weak var telemetryThreeDataLabel: UILabel!


  override func awakeFromNib() {
    super.awakeFromNib()
  }

  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }


  
}
