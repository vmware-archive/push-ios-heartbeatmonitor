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

class HeartbeatViewController: UIViewController {
    
    var heartView: HeartVectorView!
    var infoView: HeartbeatInfoView!
    var apiUrlButton: UIBarButtonItem!
    var apiUrlAlert: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PCF Push Heartbeat Monitor"
        
        
        let screenRect : CGRect = UIScreen.main.bounds
        //Due to orientation weirdness, this can be wrong unless you check
        let screenWidth : CGFloat = min(screenRect.width, screenRect.height)
        let screenHeight : CGFloat = max(screenRect.width, screenRect.height)
        let container : UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        
        self.heartView = HeartVectorView.init(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200))
        self.heartView.center = container.center
        container.addSubview(self.heartView)
        container.backgroundColor = UIColor.white
        view.addSubview(container)
        
        self.infoView = HeartbeatInfoView.init(frame: CGRect(x: 0.0, y: screenHeight - 100.0, width: container.frame.width, height: 100.0))
        container.addSubview(self.infoView)
        
        self.apiUrlAlert = getApiUrlDialog()
        
        self.apiUrlButton = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(HeartbeatViewController.showApiUrlDialog))
        
        self.navigationItem.setRightBarButton(self.apiUrlButton, animated: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.registerForHeartbeats();
        
        if EndpointHelper.getCurrentApiUrl().isEmpty {
            self.showApiUrlDialog()
        }
    }
    
    func registerForHeartbeats() {
        NotificationCenter.default.addObserver(self.infoView, selector: #selector(HeartbeatInfoView.didReceiveHeartbeat), name: NSNotification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat"), object: nil)
        NotificationCenter.default.addObserver(self.heartView, selector: #selector(HeartVectorView.beatHeart), name: NSNotification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceivedHeartbeat"), object: nil)
        NotificationCenter.default.addObserver(self.infoView, selector: #selector(HeartbeatInfoView.didReceiveError), name: NSNotification.Name(rawValue: "io.pivotal.ios.push.heartbeatmonitorReceiveError"), object: nil)
    }
    
    func showApiUrlDialog() {
        self.present(apiUrlAlert, animated: true) {
            let textField = (self.apiUrlAlert.textFields?.first)!
            textField.text = EndpointHelper.getCurrentApiUrl()
            self.textFieldDidChange(textField)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self.infoView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getApiUrlDialog() -> UIAlertController {
        let alert = UIAlertController.init(title: "Push Service URL", message: "Set your push service url", preferredStyle: UIAlertControllerStyle.alert);
        let saveAction = UIAlertAction.init(title: "Okay", style: .default) { (alertAction: UIAlertAction) in
            
            let newUrl = (alert.textFields?.first!.text)!
            if newUrl == EndpointHelper.getCurrentApiUrl() {
                NSLog("Api url unchanged. Still %@\n", newUrl)
                UIApplication.shared.registerForRemoteNotifications()
                return
            }
            
            NSLog("Unregistering from  %@", EndpointHelper.getCurrentApiUrl())
            
            PCFPush.unregisterFromPCFPushNotifications(success: {
                NSLog("Successfully unregistered from push")
                self.updateEndpointUrl(url: newUrl)
            }, failure: { (error: Error?) in
                NSLog("Error unregistering from push. %@", error.debugDescription)
                self.updateEndpointUrl(url: newUrl)
            })
            
        }
        
        saveAction.isEnabled = false;
        alert.addAction(saveAction)
        
        alert.addTextField { (textfield: UITextField) in
            textfield.placeholder = "Push service url"
            textfield.keyboardType = .URL
            textfield.addTarget(self, action: #selector(HeartbeatViewController.textFieldDidChange(_:)), for: .editingChanged)
        }

        
        return alert;
    }
    
    private func updateEndpointUrl(url: String) {
        EndpointHelper.saveApiUrl(url: url)
        UIApplication.shared.registerForRemoteNotifications()
        self.infoView.updateServiceUrl()
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        apiUrlAlert.actions.first!.isEnabled = !(textField.text?.isEmpty)!
    }
}

