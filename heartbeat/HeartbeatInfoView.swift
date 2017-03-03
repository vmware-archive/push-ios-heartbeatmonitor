//
//  HeartbeatInfoView.swift
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

class HeartbeatInfoView: UIView {
    
    var numHeartbeats = 0
    var lastHeartbeat = Date.init(timeIntervalSince1970: 0)
    var url : String = ""
    var updateTimer = Timer()
    
    let numHeartbeatsLabel = UILabel.init()
    let dateFormatter = DateFormatter.init()
    let lastHeartbeatLabel = UILabel.init()
    let urlLabel = UILabel.init()
    let errorTextView = UITextView.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = .short
        self.setupView(frame)
        readHeartbeatData()
        updateLastHeartbeatText()
        updateTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(HeartbeatInfoView.updateLastHeartbeatText), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(_ frame: CGRect){
        let labelHeight : CGFloat = 20.0
        let fontSize : CGFloat = 14.0
        let textColor = UIColor.gray
        
        numHeartbeatsLabel.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: frame.width, height: labelHeight))
        numHeartbeatsLabel.font = numHeartbeatsLabel.font.withSize(fontSize)
        numHeartbeatsLabel.textColor = textColor
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        numHeartbeatsLabel.textAlignment = NSTextAlignment.center
        numHeartbeatsLabel.accessibilityIdentifier = "numHeartbeatsLabel"
        self.addSubview(numHeartbeatsLabel)
        
        lastHeartbeatLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: numHeartbeatsLabel.frame.maxY), size: CGSize(width: frame.width, height: labelHeight))
        lastHeartbeatLabel.font = lastHeartbeatLabel.font.withSize(fontSize)
        lastHeartbeatLabel.textColor = textColor
        lastHeartbeatLabel.text = "Last Heartbeat received \(dateFormatter.string(from: lastHeartbeat))."
        lastHeartbeatLabel.textAlignment = NSTextAlignment.center
        lastHeartbeatLabel.accessibilityIdentifier = "lastHeartbeatLabel"
        self.addSubview(lastHeartbeatLabel)
        
        urlLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: lastHeartbeatLabel.frame.maxY), size: CGSize(width: frame.width, height: labelHeight))
        urlLabel.font = urlLabel.font.withSize(fontSize)
        urlLabel.textColor = textColor
        urlLabel.textAlignment = NSTextAlignment.center
        urlLabel.accessibilityIdentifier = "urlLabel"
        updateServiceUrl()
        self.addSubview(urlLabel)
        
        errorTextView.frame = CGRect(origin: CGPoint(x: 0.0, y: numHeartbeatsLabel.frame.maxY), size: CGSize(width: frame.width, height: labelHeight*3))
        errorTextView.font = errorTextView.font?.withSize(fontSize)
        errorTextView.textColor = textColor
        errorTextView.textAlignment = NSTextAlignment.center
        errorTextView.isHidden = true
        errorTextView.accessibilityIdentifier = "errorTextView"
        self.addSubview(errorTextView)
    }
    
    func didReceiveHeartbeat() {
        NSLog("received heartbeat notification")
        increment()
    }
    
    func increment(){
        NSLog("Incrementing heartbeats")
        numHeartbeats += 1
        lastHeartbeat = Date()
        persistHeartbeatData(numHeartbeats, lastReceivedTimestamp: lastHeartbeat.timeIntervalSince1970)
        updateLastHeartbeatText()
    }
    
    func updateLastHeartbeatText(){
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        var heartbeatText = "Waiting for first heartbeat..."
        let timeSince : TimeInterval = abs(lastHeartbeat.timeIntervalSinceNow)
        if (timeSince < 60) {
            heartbeatText = "Last heartbeat was moments ago."
        } else if (numHeartbeats > 0) {
            heartbeatText = "Last heartbeat was \(dateFormatter.string(from: lastHeartbeat))."
        }
        lastHeartbeatLabel.text = heartbeatText
    }
    
    func readHeartbeatData(){
        if let myDict: NSDictionary = dictionaryFromDocumentsPlist("/HeartbeatData"){
            numHeartbeats = myDict["Count"] as! Int
            lastHeartbeat = Date(timeIntervalSince1970: myDict["LastReceivedTimestamp"] as! TimeInterval)
        } else {
            NSLog("No existing Heartbeat Data found")
        }
    }
    
    func persistHeartbeatData(_ count: Int, lastReceivedTimestamp: TimeInterval) {
        let myDict: NSDictionary = NSDictionary.init(objects: [count, lastReceivedTimestamp], forKeys: ["Count" as NSCopying,"LastReceivedTimestamp" as NSCopying])
        writeDictionaryToPlist("/HeartbeatData", dict: myDict)
    }
    
    func updateServiceUrl(){
        let url = EndpointHelper.getCurrentApiUrl()
        if !url.isEmpty {
            errorTextView.isHidden = true
            lastHeartbeatLabel.isHidden = false
            urlLabel.isHidden = false
            urlLabel.text = "Monitoring \(url)"
        } else {
            errorTextView.isHidden = true
            lastHeartbeatLabel.isHidden = false
            urlLabel.isHidden = false
            urlLabel.text = "Service url was empty"
            
        }
    }
    
    func dictionaryFromBundledPlist(_ filename: String) -> NSDictionary? {
        var myDict: NSDictionary?
        if let path = Bundle.main.path(forResource: filename, ofType: "plist") {
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        return myDict
    }
    
    func dictionaryFromDocumentsPlist(_ filename: String) -> NSDictionary? {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        var path : String?
        if (paths.count > 0){
            let documentsDirectory = paths[0] as! String
            path = documentsDirectory + "\(filename).plist"
        }
        
        var myDict: NSDictionary?
        if path != nil {
            myDict = NSDictionary(contentsOfFile: path!)
        }
        
        return myDict
    }
    
    func writeDictionaryToPlist(_ filename: String, dict: NSDictionary) {
        // getting path to GameData.plist
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        var path : String = ""
        if (paths.count > 0){
            let documentsDirectory = paths[0] as! String
            path = documentsDirectory + "\(filename).plist"
        }
        
        let success = dict.write(toFile: path, atomically: true)
        if (success){
            NSLog("successful write!")
        } else {
            NSLog("Failed to write data")
        }
    }

    func didReceiveError(_ notification: Notification) {
        NSLog("didReceiveError: \(notification)")
        numHeartbeatsLabel.text = (notification as NSNotification).userInfo!["message"] as? String
        errorTextView.text = ((notification as NSNotification).userInfo!["error"] as? NSError)?.localizedDescription
        errorTextView.isHidden = false
        lastHeartbeatLabel.isHidden = true
        urlLabel.isHidden = true
        updateTimer.invalidate()
    }
}
