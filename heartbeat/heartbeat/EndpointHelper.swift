//
//  EndpointHelper.swift
//  PCF Push Heartbeat Monitor
//
//  Created by Ergin Babani on 2017-02-28.
//  Copyright © 2017 Pivotal. All rights reserved.
//

import Foundation

class EndpointHelper {
    static let API_URL_KEY = "HEARTBEAT_API_URL";
    
    // Returns the current push api url. If the user hasn't set it, return the service url from the plist.
    public class func getCurrentApiUrl() -> String {
        var  currentApiUrl = getSavedApiUrl();
        if currentApiUrl.isEmpty {
            currentApiUrl = getApiUrlFromPlist()
        }
        
        return currentApiUrl;
    }
    
    class func getApiUrlFromPlist() -> String {
        var plistDictionary : NSDictionary?
        if let path = Bundle.main.path(forResource: "Pivotal", ofType: "plist") {
            plistDictionary = NSDictionary(contentsOfFile: path)
        }
        
        if plistDictionary == nil {
            return ""
        }
        
        return plistDictionary?.value(forKey: "pivotal.push.serviceUrl") as! String
    }
    
    class func getSavedApiUrl() -> String {
        let userDefaults = UserDefaults.standard
        return userDefaults.value(forKey: API_URL_KEY) as! String? ?? ""
    }
    
    public class func saveApiUrl(url: String) {
        if url.isEmpty {
            UserDefaults.standard.removeObject(forKey: API_URL_KEY)
            return
        }
        
        UserDefaults.standard.setValue(url, forKeyPath: API_URL_KEY)
    }

}
