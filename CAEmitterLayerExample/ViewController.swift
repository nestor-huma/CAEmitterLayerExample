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
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        setupSky()
        
        configureShadow(layer: signInButton.layer)
        configureShadow(layer: registerButton.layer)
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
    
    func configureShadow(layer layer: CALayer) {
        layer.shadowOffset = CGSizeZero
        layer.shadowColor = UIColor.orangeColor().CGColor
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 1.0
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
        createCometAtLocation(sender.locationInView(view))
    }
    
}

// MARK: comets
extension ViewController {
    private var cometFadoutAnimation: String {
        return "cometFadout"
    }
    
    private var moveToSideAnimation: String {
        return "moveToSide"
    }
    
    //    private var ovalPathAnimation: String {
    //
    //    }
    
    private func createCometAtLocation(location: CGPoint) {
        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "particle")?.CGImage
        cell.birthRate = 500
        cell.lifetime = 1.0
        cell.lifetimeRange = 0.5
        cell.scaleSpeed = -1.0
        cell.alphaRange = 0.5
        cell.velocity = 150.0
        cell.yAcceleration = 200.0
        cell.velocityRange = 1.0
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

        
        createMoveToSideAnimation(emitterLayer: emitter)
    }
    
    private func createMoveToSideAnimation(emitterLayer layer: CAEmitterLayer) {
        let position = layer.emitterPosition
        
        let corners = [
            CGPointZero,
            CGPoint(x: view.bounds.width, y: 0.0),
            CGPoint(x: 0.0, y: view.bounds.height),
            CGPoint(x: view.bounds.width, y: view.bounds.height)
        ]
        
        let newPosition: CGPoint! = corners.minElement {
            return position.distanceToPoint($0) < position.distanceToPoint($1)
        }
        
        let distance = position.distanceToPoint(newPosition)
        
        let velocity = view.bounds.width
        
        let duration = CFTimeInterval(distance / velocity)
        
        let animation = CABasicAnimation(keyPath: "emitterPosition")
        animation.fromValue = NSValue(CGPoint: position)
        animation.toValue = NSValue(CGPoint: newPosition)
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        animation.setValue(layer, forKey: "layer")
        animation.setValue(moveToSideAnimation, forKey: "name")
        
        animation.delegate = self
        
        layer.emitterPosition = newPosition
        layer.addAnimation(animation, forKey: nil)
    }
    
    private func createOvalPathAnimation(emitter layer: CAEmitterLayer) {
        
        let startAngle = CGFloat(M_PI_2)
        
        let minDimension = min(view.bounds.width, view.bounds.height)
        let maxDimension = max(view.bounds.width, view.bounds.height)
        
//        let scaleTransform = (minDimension == view.bounds.width) ?
//            CGAffineTransformMakeScale(1.0, maxDimension / minDimension) :
//            CGAffineTransformMakeScale(maxDimension / minDimension, 1.0)
//        
//        let moveTransform = (minDimension == view.bounds.width) ?
//            CGAffineTransformMakeTranslation(0.0, -maxDimension/2) :
//            CGAffineTransformMakeTranslation(-maxDimension/2, 0.0)
        
        let clockwise = true
        
//        let bezierPath = UIBezierPath(arcCenter: view.center, radius: minDimension/2, startAngle: startAngle, endAngle: startAngle + CGFloat(M_PI * 2), clockwise: clockwise)
//        bezierPath.applyTransform(scaleTransform)
//        bezierPath.applyTransform(moveTransform)
        let bezierPath = UIBezierPath(ovalInRect: view.bounds)
        
        let animation = CAKeyframeAnimation(keyPath: "emitterPosition")
        animation.path = bezierPath.CGPath
        animation.beginTime = CACurrentMediaTime()
        animation.duration = 5.0
        animation.repeatCount = Float.infinity
        animation.calculationMode = kCAAnimationPaced
        
        layer.addAnimation(animation, forKey: nil)
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let name = anim.valueForKey("name") as? String, let layer = anim.valueForKey("layer") as? CAEmitterLayer {
            switch name {
            case moveToSideAnimation:
                createOvalPathAnimation(emitter: layer)
                
            case cometFadoutAnimation:
                layer.removeFromSuperlayer()
                
            default:
                break
            }
        }
    }
    
    
}
