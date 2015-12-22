//
//  PathHelper.swift
//  heartbeat
//
//  Created by DX173-XL on 2015-12-22.
//  Copyright © 2015 Pivotal. All rights reserved.
//

import Foundation
import UIKit

public func CGPointRelativeTo(originPoint : CGPoint, relativePoint : CGPoint)->CGPoint {
    return CGPoint(x: originPoint.x + relativePoint.x, y: originPoint.y + relativePoint.y)

}
public func CGPointRelativeTo(originPoint : CGPoint, x : CGFloat, y : CGFloat)->CGPoint {
    return CGPoint(x: originPoint.x + x, y: originPoint.y + y)
}
