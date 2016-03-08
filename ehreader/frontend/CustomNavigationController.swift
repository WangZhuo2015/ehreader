//
//  CustomNavigationController.swift
//  client
//
//  Created by yrtd on 15/11/23.
//  Copyright © 2015年 kuaiyong. All rights reserved.
//

import UIKit

public class CustomNavigationController: UINavigationController {
    internal(set) var screenshoots:[UIImage] = []
    
    public var canDragBack:Bool = true
    public var isMoving:Bool = false
    private var startTouch:CGPoint = CGPointZero
    
    lazy var shadowImageView:UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "leftside_shadow_bg"))
        return imageView
    }()
    
    var backgroundView:UIView?
    
    var blackMaskView:UIView?
    
    var lastScreenShootView:UIImageView?
    
    lazy var recognizer:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CustomNavigationController.paningGestureReceive(_:)))
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override public init(navigationBarClass: AnyClass!, toolbarClass: AnyClass!) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.tintColor = UIColor.redColor()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func pushViewController(viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            //viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    public override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        return super.popViewControllerAnimated(animated)
    }
}

extension CustomNavigationController: UIGestureRecognizerDelegate {
    
    func paningGestureReceive(gestureRecognizer: UIGestureRecognizer) {
        // If the viewControllers has only one vc or disable the interaction, then return.
        if viewControllers.count <= 1 || !canDragBack {
            return
        }
        // we get the touch position by the window's coordinate
        guard let window = UIApplication.sharedApplication().keyWindow else {
            return
        }
        let touchPoint = recognizer.locationInView(window)
        // begin paning, show the backgroundView(last screenshot),if not exist, create it.
        
        if recognizer.state == UIGestureRecognizerState.Began {
            isMoving = true
            startTouch = touchPoint
            if backgroundView == nil {
                let frame = view.frame
                backgroundView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
                view.superview?.insertSubview(backgroundView!, belowSubview: view)
                
                blackMaskView = UIView(frame: CGRectMake(0, 0, frame.width, frame.height))
                blackMaskView?.backgroundColor = UIColor.blackColor()
                backgroundView?.addSubview(blackMaskView!)
            }
            backgroundView?.hidden = false
            if lastScreenShootView != nil {
                lastScreenShootView?.removeFromSuperview()
            }
            if let lastScreenshooot = screenshoots.last {
                lastScreenShootView = UIImageView(image: lastScreenshooot)
                backgroundView?.insertSubview(lastScreenShootView!, belowSubview: blackMaskView!)
            }
        }else if recognizer.state == UIGestureRecognizerState.Ended {
            if touchPoint.x - startTouch.x > 50 {
                UIView.animateWithDuration(0.3, animations: { 
                    self.moveWithX(self.view.frame.width)
                }, completion: { (finished:Bool) in
                    self.popViewControllerAnimated(false)
                    self.view.frame.x = 0
                    self.isMoving = false
                    self.view.superview?.sendSubviewToBack(self.backgroundView!)
                    self.backgroundView = nil
                })
            }else {
                UIView.animateWithDuration(0.3, animations: { 
                    self.moveWithX(0)
                }, completion: { (finished:Bool) in
                    self.isMoving = false
                    self.backgroundView?.hidden = true
                    self.view.superview?.sendSubviewToBack(self.backgroundView!)
                    self.backgroundView = nil
                })
            }
            return
        }else if recognizer.state == UIGestureRecognizerState.Cancelled {
            UIView.animateWithDuration(0.3, animations: {
                self.moveWithX(0)
                }, completion: { (finished:Bool) in
                    self.isMoving = false
                    self.backgroundView?.hidden = true
                    self.view.superview?.sendSubviewToBack(self.backgroundView!)
                    self.backgroundView = nil
            })
            return
        }
        if isMoving {
            self.moveWithX(touchPoint.x - startTouch.x)
        }
    }
    
    func moveWithX(distance:CGFloat) {
        var _distance = distance > self.view.frame.width ? self.view.frame.width : distance
        _distance = distance < 0 ? 0 : distance
        
        self.view.frame.x = _distance
        let scale = (_distance/6400) + 0.95
        let alpha = 0.4 - (_distance/800)
        
        lastScreenShootView?.transform = CGAffineTransformMakeScale(scale, scale)
        blackMaskView?.alpha = alpha
    }
}

private extension UIView {
    func screenshotImage(scale: CGFloat = 0.0) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}