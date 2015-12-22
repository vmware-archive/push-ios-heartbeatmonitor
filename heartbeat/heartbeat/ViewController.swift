//
//  ViewController.swift
//  heartbeat
//
//  Created by DX173-XL on 2015-12-21.
//  Copyright © 2015 Pivotal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenRect : CGRect = UIScreen.mainScreen().bounds
        //Due to orientation weirdness, this can be wrong unless you check
        let screenWidth : CGFloat = min(screenRect.width, screenRect.height)
        let screenHeight : CGFloat = max(screenRect.width, screenRect.height)
        let container : UIView = UIView.init(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight))
        
        let heart : HeartVectorView = HeartVectorView.init(frame: CGRect(x: 0.0, y: 0.0, width: 200, height: 200))
        heart.center = container.center
        container.addSubview(heart)
        view.addSubview(container)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

