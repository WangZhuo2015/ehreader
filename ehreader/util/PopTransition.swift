//
//  PopTransition.swift
//  ehreader
//
//  Created by 周泽勇 on 16/3/7.
//  Copyright © 2016年 bravedefault. All rights reserved.
//

import UIKit

public class PopTransition: NSObject, UIViewControllerAnimatedTransitioning {
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.3
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as? GalleryWaterFlowViewController else {
            return
        }
        
        guard let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as? PhotoViewController else {
            return
        }
        
        guard let containerView = transitionContext.containerView() else {
            return
        }
        
        guard let cell = toViewController.currentSelectedCell else{
            return
        }
        
        // take snapshoot
        let snapshootView = fromViewController.imageView.snapshotViewAfterScreenUpdates(false)
        snapshootView.frame = containerView.convertRect(fromViewController.imageView.frame, fromView: fromViewController.imageView.superview)
        snapshootView.backgroundColor = UIColor.clearColor()
        fromViewController.imageView.hidden = true
        
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        containerView.addSubview(snapshootView)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveLinear, animations: {
            fromViewController.view.alpha = 0
            snapshootView.frame = containerView.convertRect(cell.imageView.frame, fromView: cell.imageView.superview)
        }) { (finished:Bool) in
            snapshootView.removeFromSuperview()
            fromViewController.imageView.hidden = false
            cell.imageView.hidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}
