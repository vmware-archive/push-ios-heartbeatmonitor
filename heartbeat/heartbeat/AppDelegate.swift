/*
 *  Copyright (C) 2015-Present Pivotal Software, Inc. All rights reserved.
 *
 *  This program and the accompanying materials are made available under
 *  the terms of the under the Apache License, Version 2.0 (the "License”);
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import UIKit
import PCFPush
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Register for push notifications with the Apple Push Notification Service (APNS).
        //
        // On iOS 8.0+ you need to provide your user notification settings by calling
        // [UIApplication.sharedDelegate registerUserNotificationSettings:] and then
        // [UIApplication.sharedDelegate registerForRemoteNotifications];
        //
        let notificationTypes : UIUserNotificationType = [.alert, .badge, .sound]
        let settings : UIUserNotificationSettings = UIUserNotificationSettings.init(types: notificationTypes, categories: nil);
        application.registerUserNotificationSettings(settings);

        window = UIWindow(frame: UIScreen.main.bounds)
        
        let mainViewController = HeartbeatViewController()
        let mainNavController = UINavigationController.init(rootViewController: mainViewController)

        mainNavController.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 167.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        mainNavController.navigationBar.barStyle = .black
        
        window?.rootViewController = mainNavController
        window?.makeKeyAndVisible()
        
        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        NSLog("User Notification Settings")
        if !EndpointHelper.getCurrentApiUrl().isEmpty {
            application.registerForRemoteNotifications();
        }
    }

    // This method is called when APNS registration succeeds.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("APNS registration succeeded!");
    
        // APNS registration has succeeded and provided the APNS device token.  Start registration with PCF Push
        // Notification Service and pass it the APNS device token.
        //
        // Required: Create a file in your project called "Pivotal.plist" in order to provide parameters for registering with
        // PCF Push Notification Service
        //
        // Optional: You can also provide a set of tags to subscribe to.
        //
        // Optional: You can also provide a device alias.  The use of this device alias is application-specific.  In general,
        // you can pass the device name.
        //
        // Optional: You can pass blocks to get callbacks after registration succeeds or fails.

        let deviceAlias = UIDevice.current.name

        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        var subscribedTags: Set<String>?
        if let dict = myDict {
            if let heartbeatTag : String = dict["Heartbeat Tag"] as? String {
                subscribedTags = [heartbeatTag]
                NSLog("\(subscribedTags!.first)) is the heartbeat tag")
            } else {
                NSLog("Heartbeat Tag is nil")
            }
        }
        NSLog("Device Alias: \(deviceAlias)")
        NSLog("Device Token: \(deviceToken)")
        NSLog("Subscribed Tags: \(subscribedTags)")
        
        let serviceInfo = PCFPushServiceInfo.init(api: EndpointHelper.getCurrentApiUrl(), devPlatformUuid: nil, devPlatformSecret: nil, prodPlatformUuid: nil, prodPlatformSecret: nil)
        
        PCFPush.setPushServiceInfo(serviceInfo);
        
        if subscribedTags != nil {
            PCFPush.registerForPCFPushNotifications(withDeviceToken: deviceToken,
                tags: subscribedTags,
                deviceAlias: deviceAlias,
                areGeofencesEnabled: false, success: {
                    NSLog("Successfully registered for PCF push notifications. Device ID is \(PCFPush.deviceUuid())")
                }, failure: {error in
                    NSLog("Error registering for PCF push notifications: \(error)")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceiveError"), object: self, userInfo: ["message":"Failed to register with PCF Push", "error": error!])
                })
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error){
        NSLog("Failed to register!")
        NSLog(error.localizedDescription)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceiveError"), object: self, userInfo: ["message":"Failed to register with APNS", "error": error])
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]){
        self.handleRemoteNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){
        self.handleRemoteNotification(userInfo)
        
        PCFPush.didReceiveRemoteNotification(userInfo, completionHandler: {(wasIgnored: Bool, fetchResult: UIBackgroundFetchResult, error: Error?) -> Void in
                completionHandler(fetchResult)
            }
        )
    }
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]?) {
        if let userDict = userInfo! as NSDictionary? {
            if (userDict["pcf.push.heartbeat.sentToDeviceAt"] != nil){
                NSLog("Received heartbeat push: \(userInfo!)")
                let notification = Notification(name: Notification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat"), object: nil)
                NotificationCenter.default.post(notification)
            } else {
                NSLog("Received non-heartbeat push: \(userInfo!)")
            }
        } else {
            NSLog("Received push message (no userInfo).")
        }
    }
}

