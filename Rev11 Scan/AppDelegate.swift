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
class AppDelegate: UIResponder, UIApplicationDelegate, ESTBeaconManagerDelegate, ESTEddystoneManagerDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  let beaconManager = ESTBeaconManager()
  let eddystoneManager = ESTEddystoneManager()


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

    self.beaconManager.delegate = self
    self.eddystoneManager.delegate = self

//    // filter by namespace
//    let namespaceUID = ESTEddystoneUID(namespaceID: "EDD1EBEAC04E5DEFA017")
////    let namespaceFilter = ESTEddystoneFilterUID(UID: namespaceUID)
//    let namespaceFilter = ESTEddystoneFilterUID(UID: namespaceUID)
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(namespaceFilter)
//
//    // filter by namespace and instance
//    let namespaceInstanceUID = ESTEddystoneUID(namespaceID: "EDD1EBEAC04E5DEFA017",
//                                               instanceID: "0BDB87539B67")
//    let namespaceInstanceFilter = ESTEddystoneFilterUID(UID: namespaceInstanceUID)
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(namespaceInstanceFilter)
//
//    // filter by URL
//    let urlFilter = ESTEddystoneFilterURL(URL: "http://my.restaurant.com/new-york-city")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(urlFilter)
//
//    // filter by domain name
//    let domainNameFilter = ESTEddystoneFilterURLDomain(URLDomain: "my.restaurant.com")
//    self.eddystoneManager.startEddystoneDiscoveryWithFilter(domainNameFilter)

    func eddystoneManager(manager: ESTEddystoneManager!, didDiscoverEddystones eddystones: [AnyObject]!, withFilter eddystoneFilter: ESTEddystoneFilter!) {
      // ...
    }

    let notificationType: UIUserNotificationType = [UIUserNotificationType.Sound, UIUserNotificationType.Alert]
    let notificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
    UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

    locationManager.delegate = self

    let manager = Manager.sharedInstance
    manager.callbackURLScheme = Manager.URLSchemes?.first

    manager["rev11Scan"] = { parameters, success, failed, cancel in

      print(parameters)
      print(success)
    }

    return true
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
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
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

