//
//  ViewController.swift
//  CAEmitterLayerExample
//
//  Created by Nestor Popko on 3/8/16.
//  Copyright © 2016 Nestor Popko. All rights reserved.
//

import UIKit

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
    
    
    // MARK: UIStatusBarStyle
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
