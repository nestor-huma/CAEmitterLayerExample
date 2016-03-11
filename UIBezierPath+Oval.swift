//
//  UIBezierPath+Oval.swift
//  CAEmitterLayerExample
//
//  Created by Admin on 3/11/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

extension UIBezierPath {
    convenience init(ovalInRect rect: CGRect, startAngle: CGFloat, endAngle: CGFloat, clockwise: Bool) {
        let center = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
        let radius = min(rect.width, rect.height) / 2
        
        self.init(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        
        let scaleTransform = (radius * 2 == rect.width) ?
            CGAffineTransformMakeScale(1.0, rect.height / rect.width) :
            CGAffineTransformMakeScale(rect.width / rect.height, 1.0)
        
        applyTransform(scaleTransform)
        applyTransform(CGAffineTransformMakeTranslation(-bounds.origin.x, -bounds.origin.y))
    }
}