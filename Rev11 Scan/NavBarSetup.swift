//
//  NavBarSetup.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 8/25/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import Foundation
import UIKit

class NavBarSetup {

  class func showLogoInNavBar(_ navController: UINavigationController, navItem: UINavigationItem) {

    let banner = UIImage(named: "logo-nav-bar")
    let imageView = UIImageView(image:banner)
    let bannerWidth = navController.navigationBar.frame.size.width
    let bannerHeight = navController.navigationBar.frame.size.height
    let bannerX = bannerWidth / 2 - banner!.size.width / 2
    let bannerY = bannerHeight / 2 - banner!.size.height / 2
    imageView.frame = CGRect(x: bannerX, y: bannerY, width: 180, height: bannerHeight)
    imageView.contentMode = UIViewContentMode.scaleAspectFit
    navItem.titleView = imageView
  }
}

