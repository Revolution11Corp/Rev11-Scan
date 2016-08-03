//
//  AppDelegate.swift
//  Rev11 Scan
//
//  Created by Sean's Macboo Pro on 6/22/16.
//  Copyright © 2016 Revolution11. All rights reserved.
//

import UIKit
import CoreLocation
import CallbackURLKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  let beaconManager = ESTBeaconManager()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    setupTabBar()

    ESTConfig.setupAppID("rev11scan-nxl", andAppToken: "d55de5f606394c3cb74f007ec8bd1244")

    URLParameter.sharedInstance.isFromFileMaker = false

    self.beaconManager.delegate = self

    let notificationType: UIUserNotificationType = [UIUserNotificationType.Sound, UIUserNotificationType.Alert]
    let notificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

    locationManager.delegate = self

    let manager = Manager.sharedInstance
    manager.callbackURLScheme = Manager.URLSchemes?.first

    CallbackURLKit.registerAction("rev11scan") { (parameters, success, failed, cancel) in

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

    tabItems[0].selectedImage = UIImage(named: "qr-tabbar-blue")
    tabItems[2].selectedImage = UIImage(named: "eddystone-tabbar-blue")

//    UITabBar.appearance().tintColor = Colors.blue
    UITabBar.appearance().barTintColor = Colors.darkGrey

    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.white], forState:.Normal)
    UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Colors.blue], forState:.Selected)

  }

  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    Manager.sharedInstance.handleOpenURL(url)
    return true
  }

  func beaconManager(manager: AnyObject, didEnterRegion region: CLBeaconRegion) {
    let notification = UILocalNotification()
    notification.alertBody = "You are now entering a Estimote beacon reagion"
    UIApplication.sharedApplication().presentLocalNotificationNow(notification)
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    URLParameter.sharedInstance.isFromFileMaker = false
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {

    let tabBarController = self.window?.rootViewController as! UITabBarController
    tabBarController.selectedIndex = 1
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

// MARK: CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {

    if let beaconRegion = region as? CLBeaconRegion {
      let notification = UILocalNotification()
      notification.alertBody = "Are you forgetting something?"
      notification.soundName = "Default"
      UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
  }
}

