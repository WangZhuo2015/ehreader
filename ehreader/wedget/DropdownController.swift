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
    
    public func presentDropdownController(dropdownController:UIViewController, height:CGFloat, foldControl:UIControl?, animated:Bool) {
        dropdownView = UIView(frame: self.view.bounds)
        dropdownView?.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        foldControl?.enabled = false
        UIView.transitionWithView(self.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.view.addSubview(self.dropdownView!)
        }) { (finished:Bool) in
            self.addChildViewController(dropdownController)
            dropdownController.view.frame = CGRectMake(0, -height, CGRectGetWidth(self.view.frame), height)
            self.view.addSubview(dropdownController.view)
            dropdownController.didMoveToParentViewController(self)
            if animated {
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    dropdownController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)
                }, completion: { (complete:Bool) in
                    foldControl?.enabled = true
                })
            }else {
                UIView.animateWithDuration(0.3, animations: {
                    dropdownController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)
                }, completion: { (finished:Bool) in
                    foldControl?.enabled = true
                })
            }
        }
    }
    
    public func dismissDropdownController(dropdownController:UIViewController, height:CGFloat, foldControl:UIControl?, animated:Bool) {
        foldControl?.enabled = false
        UIView.transitionWithView(self.view, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.dropdownView?.removeFromSuperview()
            self.dropdownView = nil
        }) { (finished:Bool) in
            UIView.animateWithDuration(0.3, animations: {
                dropdownController.view.frame = CGRectMake(0, -height, CGRectGetWidth(self.view.frame), height)
            }, completion: { (finished:Bool) in
                dropdownController.view.removeFromSuperview()
                dropdownController.removeFromParentViewController()
                dropdownController.didMoveToParentViewController(nil)
                foldControl?.enabled = true
            })
        }
    }
}