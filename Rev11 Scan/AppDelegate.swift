//
//  AppDelegate.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  let beaconManager = ESTBeaconManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    setupTabBar()
    ESTConfig.setupAppID(Keys.estimoteAppID, andAppToken: Keys.estimoteAppToken)
    URLParameter.sharedInstance.isFromFileMaker = false
    self.beaconManager.delegate = self

    let notificationType: UIUserNotificationType = [UIUserNotificationType.sound, UIUserNotificationType.alert]
    let notificationSettings = UIUserNotificationSettings(types: notificationType, categories: nil)
    UIApplication.shared.registerUserNotificationSettings(notificationSettings)

    locationManager.delegate = self

    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {

    if url.scheme! == "rev11scan" {

      let parameters = url.query?.toQueryDictionary ?? [:]

      if let url = parameters["url"] {
        URLParameter.sharedInstance.baseURL = url
        URLParameter.sharedInstance.isFromFileMaker = true
      } else {
        print("No URL sent from source app")
        // handle error UI that user will see if they mess up their URL input in FileMaker
      }
    }

    return true
  }

  func setupTabBar() {

    let tabBarController = self.window?.rootViewController as! UITabBarController
    let tabItems = tabBarController.tabBar.items! as [UITabBarItem]

    tabItems[0].selectedImage = UIImage(named: Images.qrTabBlue)
    tabItems[1].selectedImage = UIImage(named: Images.estimoteTabBlue)
    tabItems[2].selectedImage = UIImage(named: Images.eddystoneTabBlue)
    tabItems[3].selectedImage = UIImage(named: Images.beaconTabBlue)

    UITabBar.appearance().barTintColor = Colors.darkGrey

    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.white], for:UIControlState())
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.blue], for:.selected)

  }

  private func beaconManager(_ manager: AnyObject, didEnter region: CLBeaconRegion) {
    let notification = UILocalNotification()
    notification.alertBody = "You are now entering a Estimote beacon reagion"
    UIApplication.shared.presentLocalNotificationNow(notification)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    URLParameter.sharedInstance.isFromFileMaker = false
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {

    let tabBarController = self.window?.rootViewController as! UITabBarController
    tabBarController.selectedIndex = 1
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

// MARK: CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

    if region is CLBeaconRegion {
      let notification = UILocalNotification()
      notification.alertBody = "Are you forgetting something?"
      notification.soundName = "Default"
      UIApplication.shared.presentLocalNotificationNow(notification)
    }
  }
}

