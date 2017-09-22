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
