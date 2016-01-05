//
//  HeartbeatInfoView.swift
//  heartbeat
//
//  Created by Pivotal on 2016-01-05.
//  Copyright © 2016 Pivotal. All rights reserved.
//

import UIKit

class HeartbeatInfoView: UIView {
    
    var numHeartbeats = 0
    var lastHeartbeat = NSDate.init(timeIntervalSince1970: 0)
    var url = "hellfire.maybe.who.knows"
    
    let numHeartbeatsLabel = UILabel.init()
    let dateFormatter = NSDateFormatter.init()
    let lastHeartbeatLabel = UILabel.init()
    let urlLabel = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = .ShortStyle
        self.setupView(frame)
        //NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "increment", userInfo: nil, repeats: true)
    }
    
    func setupView(frame: CGRect){
        numHeartbeatsLabel.frame = CGRect(origin: CGPointZero, size: CGSize(width: frame.width, height: 30.0))
        numHeartbeatsLabel.font = numHeartbeatsLabel.font.fontWithSize(12)
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        self.addSubview(numHeartbeatsLabel)
        
        lastHeartbeatLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: numHeartbeatsLabel.frame.maxY), size: CGSize(width: frame.width, height: 30.0))
        lastHeartbeatLabel.font = lastHeartbeatLabel.font.fontWithSize(12)
        lastHeartbeatLabel.text = "Last Heartbeat received \(dateFormatter.stringFromDate(lastHeartbeat))."
        self.addSubview(lastHeartbeatLabel)
        
        urlLabel.frame = CGRect(origin: CGPoint(x: 0.0, y: lastHeartbeatLabel.frame.maxY), size: CGSize(width: frame.width, height: 30.0))
        urlLabel.font = urlLabel.font.fontWithSize(12)
        urlLabel.text = "Monitoring \(url)"
        self.addSubview(urlLabel)
    }
    
    func increment(){
        NSLog("Incrementing heartbeats")
        numHeartbeats += 1
        numHeartbeatsLabel.text = "Received \(numHeartbeats) heartbeats."
        self.updateLastHeartbeat()
    }
    
    func didReceiveHeartbeat() {
        NSLog("received heartbeat notification")
        increment()
    }
    
    func updateLastHeartbeat(){
        lastHeartbeat = NSDate()
        lastHeartbeatLabel.text = "Last Heartbeat received \(dateFormatter.stringFromDate(lastHeartbeat))"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
