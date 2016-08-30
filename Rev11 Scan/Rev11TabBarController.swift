//
//  Rev11TabBarController.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 8/2/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class Rev11TabBarController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupMiddleButton()
  }

  func setupMiddleButton() {

    let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))

    var menuButtonFrame = menuButton.frame
    menuButtonFrame.origin.y = self.view.bounds.height - menuButtonFrame.height
    menuButtonFrame.origin.x = self.view.bounds.width/2 - menuButtonFrame.size.width/2
    menuButton.frame = menuButtonFrame

    menuButton.backgroundColor = Colors.blue
    menuButton.layer.cornerRadius = menuButtonFrame.height/2
    self.view.addSubview(menuButton)

    menuButton.setImage(UIImage(named: "beacon-white"), for: UIControlState())
    menuButton.addTarget(self, action: #selector(Rev11TabBarController.menuButtonAction(_:)), for: UIControlEvents.touchUpInside)

    self.view.layoutIfNeeded()
  }

  func menuButtonAction(_ sender: UIButton) {
    self.selectedIndex = 1
  }
}
