//
//  PushTransition.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/7.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class PushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) else {
            return
        }
        
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? PhotoViewController else {
            return
        }
        
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        guard let cell = (fromViewController as? TransitionDelegate)?.currentSelectedCellForAnimation() else {
            return
        }
        
        // take snapshoot
        let snapshootView = cell.imageView.snapshotViewAfterScreenUpdates(false)
        snapshootView.frame = containerView.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
        cell.imageView.hidden = true
        
        let finalFrame = transitionContext.finalFrameForViewController(toViewController)
        let finalImageViewFrame = toViewController.imageViewContentRect
        toViewController.view.frame = finalFrame
        toViewController.view.alpha = 0
        toViewController.imageView.hidden = true
        
        containerView.addSubview(toViewController.view)
        containerView.addSubview(snapshootView)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: {
            toViewController.view.alpha = 1
            snapshootView.frame = finalImageViewFrame
        }) { (finished:Bool) in
            snapshootView.removeFromSuperview()
            toViewController.imageView.hidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}

