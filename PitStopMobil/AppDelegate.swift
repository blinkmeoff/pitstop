//
//  AppDelegate.swift
//  PitStopMobil
//
//  Created by Игорь М. on 06.08.17.
//  Copyright © 2017 com.pitStopMobil. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UIApplication.shared.applicationIconBadgeNumber = 0
    //setup google maps and firabase
    GMSServices.provideAPIKey("AIzaSyDfF-rNIlNEnC8gaijw7oF_BEXioNiLdeg")
    GMSPlacesClient.provideAPIKey("AIzaSyDfF-rNIlNEnC8gaijw7oF_BEXioNiLdeg")
    FirebaseApp.configure()
    
    window = UIWindow()
    
    window?.rootViewController =  UINavigationController(rootViewController: MainTabBarController())
    
    attemptRegisterForNotifications(application: application)
    
    return true
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    print("FCM TOKEN -", fcmToken)
  }
  
  private func attemptRegisterForNotifications(application: UIApplication) {
    print("Attempting to register APNS...")
    
    Messaging.messaging().delegate = self
    
    UNUserNotificationCenter.current().delegate = self
    
    // user notifications auth
    // all of this works for iOS 10+
    let options: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, err) in
      if let err = err {
        print("Failed to request auth:", err)
        return
      }
      
      if granted {
        print("Auth granted.")
      } else {
        print("Auth denied")
      }
    }
    
    application.registerForRemoteNotifications()
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Pass device token to auth
    Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.sandbox)
    
    // Further handling of the device token if needed by the app
    // ...
    let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02x", $1)})
    print(deviceTokenString)
  }
  
  func application(_ application: UIApplication,
                   didReceiveRemoteNotification notification: [AnyHashable : Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if Auth.auth().canHandleNotification(notification) {
      completionHandler(.noData)
      return
    }
    // This notification is not auth related, developer should handle it.
  }
  
  // listen for user notifications
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo
    
    if let _ = userInfo["newMessage"] as? String {
      if let mainTabBarController = window?.rootViewController {
        guard let mainTab = mainTabBarController.childViewControllers.first as? MainTabBarController else { return }
        if !mainTab.isClient {
          if mainTab.selectedIndex == 1 {
            completionHandler(.badge)
          }
          mainTab.tabBar.items?[1].badgeColor = .red
          mainTab.tabBar.items?[1].badgeValue = "•"
        } else {
          if mainTab.selectedIndex == 3 {
            completionHandler(.badge)
          }
          mainTab.tabBar.items?[3].badgeColor = .red
          mainTab.tabBar.items?[3].badgeValue = "•"
        }
        
      }
    }
    completionHandler(.badge)
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    let userInfo = response.notification.request.content.userInfo
    
    if let followerId = userInfo["followerId"] as? String {
      print(followerId)

    }
  }


}

