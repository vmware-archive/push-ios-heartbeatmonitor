//
//  AppDelegate.swift
//  heartbeat
//
//  Created by DX173-XL on 2015-12-21.
//  Copyright © 2015 Pivotal. All rights reserved.
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

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        NSLog("User Notification Settings")
        application.registerForRemoteNotifications();
    }
    
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void) {
        NSLog("Handling Action")
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
            PCFPush.registerForPCFPushNotificationsWithDeviceToken(deviceToken, tags: subscribedTags, deviceAlias: deviceAlias, areGeofencesEnabled: false, success: nil, failure: nil)
        }
   
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        NSLog("Failed to register!")
        NSLog(error.localizedDescription)
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

