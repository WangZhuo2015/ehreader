//
//  DropdownController.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/8.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public extension UIViewController {
    private struct AssociatedKeys {
        static var dropdownViewKey = "UIViewController.dropdownView"
        static var isAnimatingKey = "UIViewController.isAnimating"
    }

    
    public var dropdownView:UIView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.dropdownViewKey) as? UIView
        }
        set {
            if newValue != nil {
                objc_setAssociatedObject(self, &AssociatedKeys.dropdownViewKey, newValue!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    public var isAnimating:Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isAnimatingKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isAnimatingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    public func setupDropdownViewEvent(target: AnyObject?, action: Selector) {
        self.dropdownView = UIView(frame: self.view.bounds)
        let gestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        self.dropdownView?.addGestureRecognizer(gestureRecognizer)
        self.dropdownView?.userInteractionEnabled = true
    }
    
    public func presentDropdownController(dropdownController:UIViewController, height:CGFloat, foldControl:UIControl?, animated:Bool) {
        if isAnimating {
            return
        }
        if self.dropdownView == nil {
            self.dropdownView = UIView(frame: self.view.bounds)
        }
        isAnimating = true
        dropdownView?.frame = self.view.bounds
        dropdownView?.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        foldControl?.enabled = false
        
        self.view.addSubview(self.dropdownView!)
        self.addChildViewController(dropdownController)
        dropdownController.view.frame = CGRectMake(0, -height, CGRectGetWidth(self.view.frame), height)
        self.view.addSubview(dropdownController.view)
        dropdownController.didMoveToParentViewController(self)
        if animated {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                dropdownController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)
            }, completion: {[weak self] (complete:Bool) in
                foldControl?.enabled = true
                self?.isAnimating = false
            })
        }else {
            UIView.animateWithDuration(0.3, animations: {
                dropdownController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)
            }, completion: {[weak self] (finished:Bool) in
                foldControl?.enabled = true
                self?.isAnimating = false
            })
        }
    }
    
    public func dismissDropdownController(dropdownController:UIViewController, height:CGFloat, foldControl:UIControl?, animated:Bool) {
        foldControl?.enabled = false
        if isAnimating {
            return
        }
        isAnimating = true
        self.dropdownView?.removeFromSuperview()
        UIView.animateWithDuration(0.3, animations: {
            dropdownController.view.frame = CGRectMake(0, -height, CGRectGetWidth(self.view.frame), height)
        }, completion: {[weak self] (finished:Bool) in
            dropdownController.view.removeFromSuperview()
            dropdownController.removeFromParentViewController()
            dropdownController.didMoveToParentViewController(nil)
            foldControl?.enabled = true
            self?.isAnimating = false
        })
    }
}