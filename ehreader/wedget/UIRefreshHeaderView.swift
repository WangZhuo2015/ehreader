//
//  UIRefreshHeaderView.swift
//  ehreader
//
//  Created by 周泽勇 on 16/4/7.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit
import SnapKit
import NVActivityIndicatorView

public enum RefreshStatus:Int {
    case Pulling = 0
    case Normal = 1
    case Loading = 2
}

private let FlipAnimationDuration:CFTimeInterval = 0.18
private let RotateAnimationKeyPulling = "RotateAnimationKeyPulling"

let HeaderHeight:CGFloat = 40
private let ImageHeight:CGFloat = 19

@objc public protocol UIRefreshHeaderViewDelegate:NSObjectProtocol {
    func refreshHeaderViewDidTriggerRefresh(refreshHeaderView:UIRefreshHeaderView)
    
    func refreshHeaderViewDataSourceIsLoading(refreshHeaderView:UIRefreshHeaderView)->Bool
    
    optional func refreshHeaderDataSourceLastUpdated(refreshHeaderView:UIRefreshHeaderView)
}

public class UIRefreshHeaderView: UIView {
    public var status:RefreshStatus = RefreshStatus.Normal {
        didSet {
            switch self.status {
            case .Pulling:
                statusLabel.text = "松开即可刷新..."
//                let animation = CABasicAnimation(keyPath: "transform.rotation.z")
//                animation.duration = FlipAnimationDuration
//                animation.toValue = M_PI
//                animation.repeatCount = 1
//                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
//                animation.removedOnCompletion = false
//                arrowImageView.layer.addAnimation(animation, forKey: RotateAnimationKeyPulling)
//                arrowImageView.startAnimating()
                CATransaction.begin()
                CATransaction.setAnimationDuration(FlipAnimationDuration)
                arrowImageView.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1)
                CATransaction.commit()
                break
            case .Normal:
                if oldValue == .Pulling {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(FlipAnimationDuration)
                    arrowImageView.transform = CATransform3DIdentity
                    CATransaction.commit()
                }
                statusLabel.text = "下拉即可刷新..."
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                arrowImageView.hidden = false
                arrowImageView.transform = CATransform3DIdentity
                CATransaction.commit()
                break
            case .Loading:
                statusLabel.text = "加载中，请稍候..."
                arrowImageView.hidden = true
                activityIndicatorView.hidden = false
                activityIndicatorView.startAnimating()
                break
            }
        }
    }
    
    public weak var delegate:UIRefreshHeaderViewDelegate?
    
    public var inset:UIEdgeInsets = UIEdgeInsetsZero
    
    private var arrowImageView:CALayer = {
        let layer = CALayer()
        layer.contentsGravity = kCAGravityResizeAspect
        layer.contents = UIImage(named: "pull_arrow")?.CGImage
        return layer
    }()
    
    private var statusLabel:UILabel = {
        let label = UILabel(frame: CGRectZero)
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIConstants.GrapefruitColor
        label.textAlignment = NSTextAlignment.Left
        return label
    }()
    
    private var activityIndicatorView:UIActivityIndicatorView {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        indicatorView.color = UIConstants.GrapefruitColor
        return indicatorView
    }
    
    private var contentView:UIView = {
        let view = UIView(frame: CGRectZero)
        return view
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupRefreshHeaderView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupRefreshHeaderView()
    }
    
    func setupRefreshHeaderView() {
        contentView.addSubview(statusLabel)
        contentView.layer.addSublayer(arrowImageView)
        contentView.addSubview(activityIndicatorView)
        
        addSubview(contentView)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let textWidth:CGFloat = 80
        let contentWidth:CGFloat = ImageHeight + textWidth
        contentView.frame = CGRectMake((frame.width - contentWidth)/2, 0, contentWidth, HeaderHeight)
        
        activityIndicatorView.frame = CGRectMake(0, (HeaderHeight - ImageHeight)/2, ImageHeight, ImageHeight)
        arrowImageView.frame = CGRectMake(0, (HeaderHeight - ImageHeight)/2, ImageHeight, ImageHeight)
        statusLabel.frame = CGRectMake(ImageHeight, 0, textWidth, HeaderHeight)
    }
    
    public func scrollViewDidScroll(scrollView:UIScrollView) {
        let offset = self.inset.top + 65
        
        if scrollView.dragging {
            let loading = delegate?.refreshHeaderViewDataSourceIsLoading(self) ?? false
            if status == .Pulling && scrollView.contentOffset.y > -offset && scrollView.contentOffset.y < self.inset.top && !loading {
                self.status = .Normal
            }else if status == .Normal && scrollView.contentOffset.y < -offset && !loading {
                self.status = .Pulling
            }
            if scrollView.contentInset.top != 0 {
                scrollView.contentInset = self.inset
            }
        }
    }
    
    public func scrollViewDidEndDragging(scrollView:UIScrollView) {
        let offset = self.inset.top + 65
        let loading = delegate?.refreshHeaderViewDataSourceIsLoading(self) ?? false
        if scrollView.contentOffset.y < -offset && !loading {
            if UIDevice.systemVersionFloatValue() > 9 {
                scrollView.bounces = false
            }
            delegate?.refreshHeaderViewDidTriggerRefresh(self)
            self.status = .Loading
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { 
                scrollView.contentInset = UIEdgeInsetsMake(self.inset.top + 60, 0, 0, 0)
            }, completion: { (finished:Bool) in
                if UIDevice.systemVersionFloatValue() > 9 {
                    scrollView.bounces = true
                }
            })
        }
    }
    
    public func didFinishLoading(scrollView:UIScrollView) {
        self.status = .Normal
        self.activityIndicatorView.stopAnimating()
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: {
            scrollView.contentInset = self.inset
        }, completion: { (finished:Bool) in
            scrollView.contentInset = self.inset
        })
    }
}
