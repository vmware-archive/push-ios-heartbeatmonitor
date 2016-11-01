//
//  AppDelegate.swift
//  heartbeat
//
//  Copyright (C) 2016 Pivotal Software, Inc. All rights reserved. 
//  
//  This program and the accompanying materials are made available under 
//  the terms of the under the Apache License, Version 2.0 (the "License”); 
//  you may not use this file except in compliance with the License. 
//  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import PCFPush

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Register for push notifications with the Apple Push Notification Service (APNS).
        //
        // On iOS 8.0+ you need to provide your user notification settings by calling
        // [UIApplication.sharedDelegate registerUserNotificationSettings:] and then
        // [UIApplication.sharedDelegate registerForRemoteNotifications];
        //
        // On < iOS 8.0 you need to provide your remote notification settings by calling
        // [UIApplication.sharedDelegate registerForRemoteNotificationTypes:].  There are no
        // user notification settings on < iOS 8.0.
        //
        // If this line gives you a compiler error then you need to make sure you have updated
        // your Xcode to at least Xcode 6.0:
        //
        if (application.respondsToSelector(Selector("registerUserNotificationSettings:"))) {
            
            // iOS 8.0 +
            let notificationTypes : UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings : UIUserNotificationSettings = UIUserNotificationSettings.init(forTypes: notificationTypes, categories: nil);
            application.registerUserNotificationSettings(settings);
        
        } else {
            
            // < iOS 8.0
            let notificationTypes : UIRemoteNotificationType = [.Alert, .Badge, .Sound]
            application.registerForRemoteNotificationTypes(notificationTypes);
        }
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let mainViewController = HeartbeatViewController()
        let mainNavController = UINavigationController.init(rootViewController: mainViewController)

        mainNavController.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green: 167.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        mainNavController.navigationBar.barStyle = .Black
        
        window?.rootViewController = mainNavController
        window?.makeKeyAndVisible()
        
        return true
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("User Notification Settings")
        application.registerForRemoteNotifications();
    }

    // This method is called when APNS registration succeeds.
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
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

        let deviceAlias = UIDevice.currentDevice().name

        var myDict: NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        var subscribedTags: Set<String>?
        if let dict = myDict {
            if let heartbeatTag : String = dict["Heartbeat Tag"] as? String {
                subscribedTags = [heartbeatTag]
                NSLog("\(String(subscribedTags!.first as String!)) is the heartbeat tag")
            } else {
                NSLog("Heartbeat Tag is nil")
            }
        }
        NSLog("Device Alias: \(deviceAlias)")
        NSLog("Device Token: \(deviceToken)")
        NSLog("Subscribed Tags: \(subscribedTags)")
        
        if subscribedTags != nil {
            PCFPush.registerForPCFPushNotificationsWithDeviceToken(deviceToken,
                tags: subscribedTags,
                deviceAlias: deviceAlias,
                areGeofencesEnabled: false, success: {
                    NSLog("Successfully registered for PCF push notifications. Device ID is \(PCFPush.deviceUuid())")
                }, failure: {error in
                    NSLog("Error registering for PCF push notifications: \(error)")
                    NSNotificationCenter.defaultCenter().postNotificationName("io.pivotal.ios.push.heartbeatmonitorReceiveError", object: self, userInfo: ["message":"Failed to register with PCF Push", "error": error])
                })
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        NSLog("Failed to register!")
        NSLog(error.localizedDescription)
        NSNotificationCenter.defaultCenter().postNotificationName("io.pivotal.ios.push.heartbeatmonitorReceiveError", object: self, userInfo: ["message":"Failed to register with APNS", "error": error])
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
        self.handleRemoteNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void){
        self.handleRemoteNotification(userInfo)
        PCFPush.didReceiveRemoteNotification(userInfo, completionHandler: {(wasIgnored: Bool, fetchResult: UIBackgroundFetchResult, error: NSError!) -> Void in
                completionHandler(fetchResult)
            }
        )
    }
    
    func handleRemoteNotification(userInfo: [NSObject : AnyObject]?) {
        if let userDict = userInfo! as NSDictionary? {
            if (userDict["pcf.push.heartbeat.sentToDeviceAt"] != nil){
                NSLog("Received heartbeat push: \(userInfo!)")
                let notification = NSNotification(name: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat", object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            } else {
                NSLog("Received non-heartbeat push: \(userInfo!)")
            }
        } else {
            NSLog("Received push message (no userInfo).")
        }
    }
/*
    // This method is called when APNS sends a push notification to the application.
    - (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
    {
    [self handleRemoteNotification:userInfo];
    }
    
    // This method is called when APNS sends a push notification to the application when the application is
    // not running (e.g.: in the background).  Requires the application to have the Remote Notification Background Mode Capability.
    - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
    {
    [self handleRemoteNotification:userInfo];
    
    // IMPORTANT: Inform PCF Push Notification Service that this message has been received.
    [PCFPush didReceiveRemoteNotification:userInfo completionHandler:^(BOOL wasIgnored, UIBackgroundFetchResult fetchResult, NSError *error) {
    
    if (completionHandler) {
    completionHandler(fetchResult);
    }
    }];
    }
    
    // This method is called when the user touches one of the actions in a notification when the application is
    // not running (e.g.: in the background).  iOS 8.0+ only.
    - (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
    {
    NSLog(@"Handling action %@ for message %@", identifier, userInfo);
    if (completionHandler) {
    completionHandler();
    }
    }
    
    - (void) handleRemoteNotification:(NSDictionary*) userInfo
    {
    if (userInfo) {
    NSLog(@"Received push message: %@", userInfo);
    } else {
    NSLog(@"Received push message (no userInfo).");
    }
    }
*/
}

