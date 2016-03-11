//
//  ViewController.swift
//  CAEmitterLayerExample
//
//  Created by Nestor Popko on 3/8/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

// perform task after given delay (in seconds)
func delay(seconds: Double, task: () -> Void) {
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(NSEC_PER_SEC) * seconds))
    dispatch_after(time, dispatch_get_main_queue(), task)
}

func random(from: CGFloat, _ to: CGFloat) -> CGFloat {
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * (to - from) + from
}

func randomColor() -> CGColor {
    return UIColor(red: random(0, 1), green: random(0, 1), blue: random(0, 1), alpha: 1.0).CGColor
}

class ViewController: UIViewController {
    
    let skyLayer = CAGradientLayer()
    let starEmitter = CAEmitterLayer()
    
    let maxCometCount = 5
    
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupSky()
        
        label.layer.shadowOffset = CGSizeZero
        label.layer.shadowColor = UIColor.orangeColor().CGColor
        label.layer.shadowRadius = 10.0
        label.layer.shadowOpacity = 1.0
    }
    
    func setupSky() {
        view.layer.insertSublayer(skyLayer, atIndex: 0)
        view.layer.insertSublayer(starEmitter, atIndex: 1)
        
        // Gradient
        skyLayer.colors = [
            UIColor.blackColor().CGColor,
            UIColor(red: 0.3, green: 0.0, blue: 0.3, alpha: 1.0).CGColor,
        ]
        skyLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        skyLayer.endPoint = CGPoint(x: 0.3, y: 1.0)
        
        let gradientAnimation = CABasicAnimation(keyPath: "colors")
        gradientAnimation.fromValue = skyLayer.colors
        gradientAnimation.toValue = skyLayer.colors?.reverse()
        gradientAnimation.duration = 20.0
        gradientAnimation.autoreverses = true
        gradientAnimation.repeatCount = Float.infinity
        
        skyLayer.addAnimation(gradientAnimation, forKey: nil)
        
        // Particles
        let particle = CAEmitterCell()
        particle.contents = UIImage(named: "particle")?.CGImage
        particle.birthRate = 20
        particle.lifetime = 8.0
        particle.lifetimeRange = 2.0
        particle.scale = 0.5
        particle.scaleRange = 0.4
        particle.scaleSpeed = 0.5
        particle.alphaRange = 0.5
        particle.velocity = 1.0
        particle.velocityRange = 1.0
        particle.alphaSpeed = -1.0/(particle.lifetime - particle.lifetimeRange)
        particle.color = UIColor(red: 0.9, green: 0.9, blue: 0.5, alpha: 1.0).CGColor
        particle.blueRange = 0.5
        
        starEmitter.emitterShape = kCAEmitterLayerRectangle
        starEmitter.emitterCells = [particle]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skyLayer.frame = view.bounds
        starEmitter.frame = view.bounds
        starEmitter.emitterSize = view.bounds.size
        starEmitter.emitterPosition = view.center
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: tap
    @IBAction func viewTapped(sender: UITapGestureRecognizer) {
        let emitters = view.layer.sublayers?.filter {
            $0.isKindOfClass(CAEmitterLayer)
        }
        
        let cometsCount = emitters!.count - 1
        
        if cometsCount < maxCometCount {
            createCometAtLocation(sender.locationInView(view))
        }
    }
}


// MARK: comets
extension ViewController {
    
    private func createCometAtLocation(location: CGPoint) {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "particle")?.CGImage
        cell.birthRate = 500
        cell.lifetime = 1.0
        cell.lifetimeRange = 0.5
        cell.scaleSpeed = -cell.scale
        cell.alphaRange = 0.5
        cell.alphaSpeed = -0.5
        cell.velocity = 50.0
        cell.yAcceleration = 200.0
        cell.emissionLongitude = CGFloat(-M_PI_2)
        cell.emissionRange = CGFloat(M_PI)
        cell.color = randomColor()
        cell.redRange = 0.3
        cell.greenRange = 0.3
        cell.blueRange = 0.3
        
        let emitter = CAEmitterLayer()
        emitter.frame = view.bounds
        emitter.emitterShape = kCAEmitterLayerPoint
        emitter.emitterPosition = location
        view.layer.addSublayer(emitter)
        
        emitter.emitterCells = [cell]
        
        createAnimations(emitterLayer: emitter)
    }
    
    private func createAnimations(emitterLayer layer: CAEmitterLayer) {
        // Move to side animation
        
        let bounds = layer.bounds
        
        let endPoint = (layer.emitterPosition.x > view.bounds.width/2) ?
            CGPoint(x: 0.0, y: view.bounds.height/2) :
            CGPoint(x: view.bounds.width, y: view.bounds.height/2)
        
        let controlPoint = CGPoint(x: bounds.width/2, y: -bounds.height/2)
        
        let path = UIBezierPath()
        path.moveToPoint(layer.emitterPosition)
        path.addQuadCurveToPoint(endPoint, controlPoint: controlPoint)
        
        let moveToSide = CAKeyframeAnimation(keyPath: "emitterPosition")
        moveToSide.path = path.CGPath
        moveToSide.duration = 2.0
        moveToSide.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        moveToSide.removedOnCompletion = false
        moveToSide.fillMode = kCAFillModeForwards
        
        layer.addAnimation(moveToSide, forKey: nil)
        
        
        // Move around ovel animation
        let clockwise = endPoint.x > bounds.width/2
        
        let middleRight = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let startAngle = atan2(endPoint.y - middleRight.y, endPoint.x - middleRight.x)
        
        let endAngle = clockwise ? startAngle + CGFloat(M_PI * 2) : startAngle - CGFloat(M_PI * 2)
        
        let moveAroundOval = CAKeyframeAnimation(keyPath: "emitterPosition")
        moveAroundOval.path = UIBezierPath(ovalInRect: layer.bounds, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise).CGPath
        moveAroundOval.beginTime = CACurrentMediaTime() + moveToSide.duration
        moveAroundOval.duration = 3.0
        moveAroundOval.repeatCount = 2.5
        moveAroundOval.calculationMode = kCAAnimationPaced
        moveAroundOval.fillMode = kCAFillModeForwards
        moveAroundOval.removedOnCompletion = false
        
        layer.addAnimation(moveAroundOval, forKey: nil)
        
        
        // Reduce birthrate animation
        let disappear = CABasicAnimation(keyPath: "birthRate")
        disappear.fromValue = layer.birthRate
        disappear.toValue = 0.0
        disappear.duration = moveAroundOval.duration * Double(moveAroundOval.repeatCount)
        disappear.beginTime = moveAroundOval.beginTime
        disappear.removedOnCompletion = false
        disappear.fillMode = kCAFillModeForwards
        
        layer.addAnimation(disappear, forKey: nil)
        
        delay(disappear.beginTime + disappear.duration - CACurrentMediaTime()) {
            layer.removeFromSuperlayer()
        }
    }
}


