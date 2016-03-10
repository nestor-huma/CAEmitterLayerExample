//
//  CGPoint+Distance.swift
//  CAEmitterLayerExample
//
//  Created by Nestor Popko on 3/10/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    static func distanceBetweenPoints(a a: CGPoint, b: CGPoint) -> CGFloat {
        return a.distanceToPoint(b)
    }
    
    func distanceToPoint(point: CGPoint) -> CGFloat {
        return sqrt( (point.x - x) * (point.x - x) + (point.y - y) * (point.y - y) )
    }
}