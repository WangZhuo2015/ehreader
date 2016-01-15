//
//  StatusBackgroundView.swift
//  client
//
//  Created by yrtd on 15/12/1.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import SnapKit

/**
 The BackgroundView's status

 - Loading: Show a waiting status in background view
 - Failed:  Show a failed status in background view
 - Hidden:  hidden backgound view
 */
public enum BackgroundViewStatus:String {
    case Loading = "Loading"
    case Failed = "Falied"
    case Hidden = "Hidden"
}

private let rotateAnimationKey = "rotation"

public class LoadingView: UIView {
    var loadingImageView:UIImageView = UIImageView(frame: CGRectZero)
    var loadingArcImageView:UIImageView = UIImageView(frame: CGRectZero)
    var hintLabel = UILabel(frame: CGRectZero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLoadingView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLoadingView()
    }
    
    private func setupLoadingView() {
        loadingImageView.image = UIImage(named: "loading_bg")
        loadingArcImageView.image = UIImage(named: "loading_arc")
        hintLabel.text = "努力加载中，请稍候..."
        hintLabel.textAlignment = NSTextAlignment.Center
        hintLabel.textColor = UIColor.createColor(78, green: 78, blue: 78, alpha: 1)
        hintLabel.font = UIFont.systemFontOfSize(12)
        
        addSubview(loadingImageView)
        addSubview(loadingArcImageView)
        addSubview(hintLabel)
        
        loadingImageView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(42)
            make.height.equalTo(42)
        }
        
        loadingArcImageView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(43)
            make.height.equalTo(43)
        }
        
        hintLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(loadingArcImageView.snp_bottom).offset(10)
            make.height.equalTo(16)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
    
    public func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 1.5
        animation.toValue = 2*M_PI
        animation.repeatCount = MAXFLOAT
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.removedOnCompletion = false
        loadingArcImageView.layer.addAnimation(animation, forKey: rotateAnimationKey)
    }
    
    public func stopAnimation() {
        loadingArcImageView.layer.removeAnimationForKey(rotateAnimationKey)
    }
}

public class LoadingFailView: UIView {
    private var imageView:UIImageView = UIImageView(frame: CGRectZero)
    private var hintLabel:UILabel = UILabel(frame: CGRectZero)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupLoadingFailView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupLoadingFailView()
    }
    
    private func setupLoadingFailView() {
        imageView.image = UIImage(named: "load_failed")
        
        hintLabel.textColor = UIColor.createColor(120, green: 120, blue: 120, alpha: 1)
        hintLabel.text = "加载失败 点击重新加载"
        hintLabel.textAlignment = NSTextAlignment.Center
        hintLabel.font = UIFont.systemFontOfSize(15)
        
        addSubview(imageView)
        addSubview(hintLabel)
        
        imageView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self)
            make.width.equalTo(45)
            make.height.equalTo(45)
        }
        
        hintLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(imageView.snp_bottom).offset(10)
            make.height.equalTo(16)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
}

public class BackgroundView: UIControl {
    public var loadingView:LoadingView = LoadingView(frame: CGRectZero)
    public var loadingFailView:LoadingFailView = LoadingFailView(frame: CGRectZero)
    
    public var status:BackgroundViewStatus = BackgroundViewStatus.Loading {
        didSet {
            //dispatch_async(dispatch_get_main_queue()) { () -> Void in
                switch self.status {
                case .Loading:
                    self.alpha = 1
                    self.loadingView.hidden = false
                    self.loadingFailView.hidden = true
                    self.loadingView.startAnimation()
                    break
                case .Hidden:
                    self.loadingView.hidden = true
                    self.loadingFailView.hidden = true
                    self.loadingView.stopAnimation()
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.alpha = 0
                    })
                    break
                case .Failed:
                    self.alpha = 1
                    self.loadingView.hidden = true
                    self.loadingFailView.hidden = false
                    self.loadingView.stopAnimation()
                    break
                }
            //}
        }
    }
    
    public override init(frame:CGRect) {
        super.init(frame: frame)
        self.setupBackgroundView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupBackgroundView()
    }
    
    private func setupBackgroundView() {
        addSubview(loadingView)
        addSubview(loadingFailView)
        loadingView.hidden = true
        loadingFailView.hidden = true
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.whiteColor()
        
        loadingFailView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
        
        loadingView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if self.status != BackgroundViewStatus.Failed {
            return
        }
        
        guard let location = touches.first?.locationInView(self) else {
            return
        }
        
        if CGRectContainsPoint(bounds, location) {
            self.status = BackgroundViewStatus.Loading
            sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
    }
    
    public override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        if self.status != BackgroundViewStatus.Failed {
            return
        }
        
        guard let location = touch?.locationInView(self) else {
            return
        }
        
        if CGRectContainsPoint(bounds, location) {
            self.status = BackgroundViewStatus.Loading
            sendActionsForControlEvents(UIControlEvents.TouchUpInside)
        }
    }
}
