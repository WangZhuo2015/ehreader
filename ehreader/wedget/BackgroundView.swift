//
//  StatusBackgroundView.swift
//  client
//
//  Created by yrtd on 15/12/1.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

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
    var activityIndicatorView:NVActivityIndicatorView = {
        let activityIndicatorView = NVActivityIndicatorView(frame: CGRectZero, type: NVActivityIndicatorType.BallClipRotatePulse, color: UIConstants.GrapefruitColor, size: CGSizeMake(40, 40))
        return activityIndicatorView
    }()
    
    
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
        hintLabel.text = "努力加载中，请稍候..."
        hintLabel.textAlignment = NSTextAlignment.Center
        hintLabel.textColor = UIColor.createColor(78, green: 78, blue: 78, alpha: 1)
        hintLabel.font = UIFont.systemFontOfSize(12)
        
        addSubview(activityIndicatorView)
        addSubview(hintLabel)
        
        activityIndicatorView.snp_makeConstraints { (make) in
            make.top.equalTo(100)
            make.centerX.equalTo(self)
        }
        
        hintLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(activityIndicatorView.snp_bottom).offset(40)
            make.height.equalTo(16)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
        }
    }
    
    public func startAnimation() {
        activityIndicatorView.startAnimation()
    }
    
    public func stopAnimation() {
        activityIndicatorView.stopAnimation()
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
            make.top.equalTo(self).offset(20)
            make.leading.trailing.bottom.equalTo(self)
        }
        
        loadingView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self).offset(20)
            make.leading.trailing.bottom.equalTo(self)
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
