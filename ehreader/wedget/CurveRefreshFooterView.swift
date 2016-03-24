//
//  CurveRefreshFooterView.swift
//  AnimatedCurveDemo-Swift
//
//  Created by Kitten Yang on 1/18/16.
//  Copyright © 2016 Kitten Yang. All rights reserved.
//

import UIKit

class CurveRefreshFooterView: UIView {

    /// 需要滑动多大距离才能松开
    var pullDistance: CGFloat = 0.0
    /// 刷新执行的具体操作
    var refreshingBlock: RefreshingBlock?
    
    private var progress: CGFloat = 0.0 {
        didSet{
            if !_associatedScrollView.tracking {
                //labelView.loading = true
            }
            
            if !willEnd && !loading {
                //labelView.progress =  progress
            }
            
            let diff =  _associatedScrollView.contentOffset.y - (_associatedScrollView.contentSize.height - _associatedScrollView.frame.height) - pullDistance + 10.0;
            
            if diff > 0 {
                if !_associatedScrollView.tracking && !hidden {
                    if !notTracking {
                        notTracking = true
                        loading = true
                        print("旋转")
                        
                        //旋转...
                        curveView.startAnimating()
                        UIView.animateWithDuration(0.3, animations: { [weak self] () -> Void in
                            if let strongSelf = self {
                                strongSelf._associatedScrollView.contentInset = UIEdgeInsetsMake(strongSelf.originOffset, 0, strongSelf.pullDistance, 0)
                            }
                            }, completion: { [weak self] (finished) -> Void in
                                if let strongSelf = self{
                                    strongSelf.refreshingBlock?()
                                }
                        })
                    }
                    
                }
                
            }else{
                curveView.stopAnimating()
            }
        }
        
    }
    private var _associatedScrollView: UIScrollView!
    
    private var curveView: UIActivityIndicatorView!
    private var hintLabel: UILabel?
    private var contentSize: CGSize?
    private var originOffset: CGFloat!
    private var willEnd: Bool = false
    private var notTracking: Bool = false
    private(set) var loading: Bool = false
    
    init(associatedScrollView: UIScrollView, withNavigationBar: Bool) {
        super.init(frame: CGRectMake(associatedScrollView.frame.width/2-200/2, associatedScrollView.frame.height, 200, 100))
        if withNavigationBar {
            originOffset = 64.0
        }else{
            originOffset = 0.0
        }
        _associatedScrollView = associatedScrollView
        setUp()
        _associatedScrollView.addObserver(self, forKeyPath: "contentOffset", options: [.New, .Old], context: nil)
        _associatedScrollView.addObserver(self, forKeyPath: "contentSize", options: [.New, .Old], context: nil)
        hidden = true
        _associatedScrollView.insertSubview(self, atIndex: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        _associatedScrollView.removeObserver(self, forKeyPath: "contentOffset")
        _associatedScrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    func stopRefreshing() {
        willEnd = true
        progress = 1.0
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseInOut, animations: { [weak self] () -> Void in
            if let strongSelf = self {
                strongSelf.alpha = 0.0
                strongSelf._associatedScrollView.contentInset = UIEdgeInsetsMake(strongSelf.originOffset, 0, 0, 0)
            }
            
            }) { [weak self] (finished) -> Void in
                if let strongSelf = self {
                    strongSelf.alpha = 1.0
                    strongSelf.willEnd = false
                    strongSelf.notTracking = false
                    strongSelf.loading = false
                    strongSelf.curveView.stopInfiniteRotation()
                }
        }
        
    }
    
}


extension CurveRefreshFooterView {
    internal func setNoMoreLoading() {
        self.curveView.removeFromSuperview()
        self.hintLabel = UILabel(frame: CGRectMake((frame.width - 100)/2, 0, 100, frame.height))
        self.hintLabel!.text = "没有更多内容了"
        hintLabel!.textColor = UIColor.redColor()
        hintLabel!.font = UIFont.systemFontOfSize(12)
        insertSubview(hintLabel!, atIndex: 0)
    }
    
    func reset() {
        self.hintLabel?.removeFromSuperview()
        curveView = UIActivityIndicatorView(frame: CGRectMake((frame.width - 20)/2, 0, 20, frame.height))
        curveView.tintColor = UIColor.redColor()
        insertSubview(curveView, atIndex: 0)
    }
    
    private func setUp() {
        pullDistance = 99;
        curveView = UIActivityIndicatorView(frame: CGRectMake((frame.width - 20)/2, 0, 20, frame.height))
        curveView.tintColor = UIColor.redColor()
        insertSubview(curveView, atIndex: 0)
    }
}

// MARK : KVO

extension CurveRefreshFooterView {
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if keyPath == "contentSize" {
            if let change = change {
                contentSize = change[NSKeyValueChangeNewKey]?.CGSizeValue()
                if let contentSize = contentSize {
                    if contentSize.height > 0.0 {
                        hidden = false
                    }
                    frame = CGRectMake(_associatedScrollView.frame.width/2-200/2, contentSize.height, 200, 100);
                }
            }
        }

        if keyPath == "contentOffset" {
            if let change = change {
                let contentOffset = change[NSKeyValueChangeNewKey]?.CGPointValue
                if let contentOffset = contentOffset, let contentSize = contentSize {
                    if contentOffset.y >= (contentSize.height - _associatedScrollView.frame.height) {
                        center = CGPointMake(center.x, contentSize.height + (contentOffset.y - (contentSize.height - _associatedScrollView.frame.height))/2);

                        progress = max(0.0, min((contentOffset.y - (contentSize.height - _associatedScrollView.frame.height)) / pullDistance, 1.0))

                    }
                }
            }
        }
    }
}
