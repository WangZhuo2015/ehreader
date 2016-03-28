//
//  ImageProgressView.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/28.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class ImageProgressView: UIView {
    public var indeterminate:Bool = true
    public var progress:CGFloat = 0
    public var showsText:Bool = false {
        didSet {
            self.layoutTextLabel()
        }
    }
    
    public var lineWidth:CGFloat = 3
    public var radius:CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    public var textColor:UIColor = UIColor.blackColor()
    public var textSize:CGFloat = 12
    public var blurEffect:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light) {
        didSet {
            let visualEffectView = UIVisualEffectView(effect: self.blurEffect)
            visualEffectView.frame = bounds
            self.backgroundView = visualEffectView
            if self.usesVibrancyEffect {
                applyVibrancyEffect()
            }
        }
    }
    
    func applyVibrancyEffect()  {
        self.backgroundLayer.removeFromSuperlayer()
        self.textLabel.removeFromSuperview()
        let visualEffectView = self.backgroundView as! UIVisualEffectView
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(forBlurEffect: self.blurEffect))
        vibrancyEffectView.frame = visualEffectView.bounds
        visualEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(self.textLabel)
        vibrancyEffectView.contentView.layer.addSublayer(self.backgroundLayer)
    }
    
    func ignoreVibrancyEffect() {
        self.backgroundLayer.removeFromSuperlayer()
        textLabel.removeFromSuperview()
        self.backgroundView.layer.addSublayer(self.backgroundLayer)
        backgroundView.addSubview(textLabel)
    }
    
    
    public var usesVibrancyEffect:Bool = true {
        didSet {
            if usesVibrancyEffect {
                applyVibrancyEffect()
            }else {
                ignoreVibrancyEffect()
            }
        }
    }
    
    override public var tintColor: UIColor! {
        didSet {
            progressLayer.strokeColor = tintColor.CGColor
        }
    }
    
    private var backgroundLayer:CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.clearColor().CGColor
        return layer
    }()
    private lazy var progressLayer:CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = self.tintColor.CGColor
        layer.lineWidth = self.lineWidth
        layer.strokeStart = 0
        layer.strokeEnd = 0
        return layer
    }()
    
    public var backgroundView:UIView = UIView(frame:CGRectZero) {
        didSet {
            if backgroundView.superview == nil {
                backgroundView.removeFromSuperview()
            }
            backgroundView.frame = bounds
            backgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
            backgroundLayer.removeFromSuperlayer()
            textLabel.removeFromSuperview()
            backgroundView.layer.addSublayer(backgroundLayer)
            backgroundView.addSubview(textLabel)
            addSubview(backgroundView)
        }
        
    }
    
    public lazy var textLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = self.tintColor
        label.font = UIFont(name: "AvenirNext-Medium", size: 12)
        label.hidden = true
        return label
    }()
    
    public func setProgress(progress:CGFloat, animated:Bool) {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageProgressView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageProgressView()
    }
    
    private func setupImageProgressView() {
        tintColor = UIColor.createColor(181, green: 182, blue: 255, alpha: 1)
        self.backgroundLayer.addSublayer(self.progressLayer)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.frame = self.bounds
        
        let path = UIBezierPath()
        path.lineCapStyle = CGLineCap.Butt
        path.lineWidth = self.lineWidth
        path.addArcWithCenter(self.backgroundView.center, radius: self.radius + self.lineWidth/2, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI + M_PI_2), clockwise: true)
        progressLayer.path = path.CGPath
        
        layoutTextLabel()
    }
    
    func layoutTextLabel()  {
        textLabel.hidden = !self.showsText || self.indeterminate
        
        if !self.textLabel.hidden {
            textLabel.textColor = self.textColor
            if textSize > 0 {
                textLabel.font = self.textLabel.font.fontWithSize(textSize)
            }
            textLabel.sizeToFit()
            textLabel.center = backgroundView.center
        }
    }
}
